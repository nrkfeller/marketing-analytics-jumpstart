--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_performance_analysis`(
  INOUT performance_date DATE,
  INOUT metric_type STRING,
  OUT analysis_count INT64
)
BEGIN
  DECLARE performance_prompt STRING;
  DECLARE metrics_data STRING;
  
  SET performance_date = IFNULL(performance_date, CURRENT_DATE());
  SET metric_type = IFNULL(metric_type, 'engagement');
  
  SET metrics_data = (
    SELECT STRING_AGG(
      CONCAT(
        'User: ', user_pseudo_id,
        ', Sessions: ', CAST(sessions AS STRING),
        ', Events: ', CAST(total_events AS STRING),
        ', Revenue: ', CAST(total_revenue AS STRING)
      ), 
      '; '
    )
    FROM `{{project_id}}.feature_store.user_lookback_metrics`
    WHERE feature_date = performance_date
    LIMIT 60
  );
  
  SET performance_prompt = CONCAT(
    'Analyze performance metrics of type "', metric_type, '" for date ', 
    CAST(performance_date AS STRING), '. Performance data: ',
    IFNULL(metrics_data, 'No performance data available'),
    '. Provide insights on performance trends, key drivers, and optimization opportunities.'
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT performance_prompt AS prompt),
    STRUCT(
      0.35 AS temperature,
      1024 AS max_output_tokens,
      0.88 AS top_p,
      40 AS top_k
    )
  );
  
  SET analysis_count = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.performance_analysis_results` (
    performance_date,
    metric_type,
    analysis_count,
    created_timestamp
  )
  VALUES (
    performance_date,
    metric_type,
    analysis_count,
    CURRENT_TIMESTAMP()
  );
  
END;
