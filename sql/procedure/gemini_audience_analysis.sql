--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_audience_analysis`(
  INOUT analysis_date DATE,
  INOUT audience_segment STRING,
  OUT analysis_results INT64
)
BEGIN
  DECLARE audience_prompt STRING;
  DECLARE audience_data STRING;
  
  SET analysis_date = IFNULL(analysis_date, CURRENT_DATE());
  SET audience_segment = IFNULL(audience_segment, 'all_audiences');
  
  SET audience_data = (
    SELECT STRING_AGG(
      CONCAT(
        'User: ', user_pseudo_id,
        ', Country: ', geo_country,
        ', Device: ', device_category,
        ', Source: ', first_user_source
      ), 
      '; '
    )
    FROM `{{project_id}}.feature_store.user_dimensions`
    WHERE feature_date = analysis_date
    LIMIT 75
  );
  
  SET audience_prompt = CONCAT(
    'Analyze audience segment "', audience_segment, '" for date ', 
    CAST(analysis_date AS STRING), '. Audience data: ',
    IFNULL(audience_data, 'No audience data available'),
    '. Provide insights on audience characteristics, behavior patterns, and segmentation recommendations.'
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT audience_prompt AS prompt),
    STRUCT(
      0.3 AS temperature,
      1024 AS max_output_tokens,
      0.9 AS top_p,
      40 AS top_k
    )
  );
  
  SET analysis_results = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.audience_analysis_results` (
    analysis_date,
    audience_segment,
    analysis_results,
    created_timestamp
  )
  VALUES (
    analysis_date,
    audience_segment,
    analysis_results,
    CURRENT_TIMESTAMP()
  );
  
END;
