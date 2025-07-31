--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_marketing_insights`(
  INOUT campaign_date DATE,
  INOUT campaign_type STRING,
  OUT insights_generated INT64
)
BEGIN
  DECLARE marketing_prompt STRING;
  DECLARE campaign_data STRING;
  
  SET campaign_date = IFNULL(campaign_date, CURRENT_DATE());
  SET campaign_type = IFNULL(campaign_type, 'general');
  
  SET campaign_data = (
    SELECT STRING_AGG(
      CONCAT(
        'User: ', user_pseudo_id,
        ', Propensity: ', CAST(will_purchase AS STRING),
        ', Engagement: ', CAST(engagement_score AS STRING)
      ), 
      '; '
    )
    FROM `{{project_id}}.feature_store.purchase_propensity_label`
    WHERE feature_date = campaign_date
    LIMIT 50
  );
  
  SET marketing_prompt = CONCAT(
    'Analyze marketing campaign performance for "', campaign_type, '" on ', 
    CAST(campaign_date AS STRING), '. Data: ',
    IFNULL(campaign_data, 'No campaign data available'),
    '. Provide insights on campaign effectiveness, audience targeting, and optimization recommendations.'
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT marketing_prompt AS prompt),
    STRUCT(
      0.4 AS temperature,
      1024 AS max_output_tokens,
      0.85 AS top_p,
      40 AS top_k
    )
  );
  
  SET insights_generated = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.marketing_analysis_results` (
    campaign_date,
    campaign_type,
    insights_generated,
    created_timestamp
  )
  VALUES (
    campaign_date,
    campaign_type,
    insights_generated,
    CURRENT_TIMESTAMP()
  );
  
END;
