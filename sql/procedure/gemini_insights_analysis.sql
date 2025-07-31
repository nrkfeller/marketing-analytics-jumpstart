--
--
--

CREATE OR REPLACE PROCEDURE `{{project_id}}.gemini_insights.gemini_insights_analysis`(
  INOUT analysis_date DATE,
  INOUT input_query STRING,
  OUT insights_generated INT64
)
BEGIN
  DECLARE query_result STRING;
  DECLARE analysis_prompt STRING;
  
  SET analysis_date = IFNULL(analysis_date, CURRENT_DATE());
  
  SET analysis_prompt = CONCAT(
    'Analyze the following marketing data and provide insights: ',
    input_query,
    ' Focus on trends, patterns, and actionable recommendations for date: ',
    CAST(analysis_date AS STRING)
  );
  
  CALL ML.GENERATE_TEXT(
    MODEL `{{project_id}}.gemini_insights.gemini_1_5_pro`,
    (SELECT analysis_prompt AS prompt),
    STRUCT(
      0.2 AS temperature,
      1024 AS max_output_tokens,
      0.8 AS top_p,
      40 AS top_k
    )
  );
  
  SET insights_generated = 1;
  
  INSERT INTO `{{project_id}}.gemini_insights.analysis_results` (
    analysis_date,
    query_input,
    insights_generated,
    created_timestamp
  )
  VALUES (
    analysis_date,
    input_query,
    insights_generated,
    CURRENT_TIMESTAMP()
  );
  
END;
