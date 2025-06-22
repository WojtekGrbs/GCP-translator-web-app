openapi: 3.0.0
info:
  title: Translator API
  description: API Gateway for the translator web app.
  version: "1.0.0"
paths:
  /translate:
    post:
      summary: Translate text
      operationId: translateText
      requestBody:
        description: Translation request payload
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                text:
                  type: string
                  description: The text to translate.
                source_language:
                  type: string
                  description: Source language code (e.g., "en").
                target_language:
                  type: string
                  description: Target language code (e.g., "es").
      responses:
        "200":
          description: A successful translation response
          content:
            application/json:
              schema:
                type: object
                properties:
                  original_text:
                    type: string
                  translated_text:
                    type: string
        "400":
          description: Bad Request
      x-google-backend:
        address: "${function_url}"
        path_translation: APPEND_PATH_TO_ADDRESS