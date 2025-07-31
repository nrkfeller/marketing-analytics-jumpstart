--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_trend_analysis`(
  INOUT trend_date DATE,
  INOUT trend_category STRING,
  OUT trends_identified INT64
)
BEGIN
  DECLARE trend_prompt STRING;
  DECLARE trend_data STRING;
  
  SET trend_date = IFNULL(trend_date, CURRENT_DATE());
  SET trend_category = IFNULL(trend_category, 'user_behavior');
  
  SET trend_data = (
    SELECT STRING_AGG(
      CONCAT(
        'Date: ', CAST(feature_date AS STRING),
        ', User: ', user_pseudo_id,
        ', Metrics: Sessions=', CAST(sessions AS STRING),
        ', Revenue=', CAST(total_revenue AS STRING)
      ), 
      '; '
    )
    FROM `{{project_id}}.feature_store.user_rolling_window_metrics`
    WHERE feature_date BETWEEN DATE_SUB(trend_date, INTERVAL 30 DAY) AND trend_date
    LIMIT 80
  );
  
  SET trend_prompt = CONCAT(
    'Analyze trends in "', trend_category, '" category up to date ', 
    CAST(trend_date AS STRING), '. Trend data over 30 days: ',
    IFNULL(trend_data, 'No trend data available'),
    '. Identify patterns, seasonal effects, and emerging trends with actionable insights.'
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT trend_prompt AS prompt),
    STRUCT(
      0.4 AS temperature,
      1024 AS max_output_tokens,
      0.9 AS top_p,
      40 AS top_k
    )
  );
  
  SET trends_identified = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.trend_analysis_results` (
    trend_date,
    trend_category,
    trends_identified,
    created_timestamp
  )
  VALUES (
    trend_date,
    trend_category,
    trends_identified,
    CURRENT_TIMESTAMP()
  );
  
END;
