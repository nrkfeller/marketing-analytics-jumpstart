--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_customer_insights`(
  INOUT analysis_date DATE,
  INOUT customer_segment STRING,
  OUT insights_count INT64
)
BEGIN
  DECLARE customer_prompt STRING;
  DECLARE segment_data STRING;
  
  SET analysis_date = IFNULL(analysis_date, CURRENT_DATE());
  SET customer_segment = IFNULL(customer_segment, 'all_customers');
  
  SET segment_data = (
    SELECT STRING_AGG(
      CONCAT(
        'Customer ID: ', user_pseudo_id,
        ', Segment: ', customer_segment,
        ', Value: ', CAST(customer_lifetime_value AS STRING)
      ), 
      '; '
    )
    FROM `{{project_id}}.feature_store.customer_lifetime_value_label`
    WHERE feature_date = analysis_date
    LIMIT 100
  );
  
  SET customer_prompt = CONCAT(
    'Analyze customer segment "', customer_segment, '" data: ',
    IFNULL(segment_data, 'No data available'),
    '. Provide insights on customer behavior, value patterns, and recommendations for engagement strategies.'
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT customer_prompt AS prompt),
    STRUCT(
      0.3 AS temperature,
      1024 AS max_output_tokens,
      0.9 AS top_p,
      40 AS top_k
    )
  );
  
  SET insights_count = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.customer_analysis_results` (
    analysis_date,
    customer_segment,
    insights_count,
    created_timestamp
  )
  VALUES (
    analysis_date,
    customer_segment,
    insights_count,
    CURRENT_TIMESTAMP()
  );
  
END;
