swagger: "2.0"
info:
  title: "Translator API"
  description: "API for translating text."
  version: "1.0.0"

schemes:
  - "https"
paths:
  /translate:
    options:
      operationId: generateOptions
      summary: "CORS support"
      security: []
      responses:
        '204':
          description: "CORS preflight"
          headers:
            Access-Control-Allow-Origin:
              type: string
              default: "https://micro-eye-455517-a2.web.app"
            Access-Control-Allow-Methods:
              type: string
              default: "POST, OPTIONS"
            Access-Control-Allow-Headers:
              type: string
              default: "Content-Type"
            Access-Control-Max-Age:
              type: string
              default: "3600"
      x-google-backend:
        address: ${function_url}
        protocol: "http/1.1"
        
    post:
      operationId: translateText  # Unique identifier for this operation
      summary: "Translate text"
      consumes:
        - "application/json"
      produces:
        - "application/json"
      security:
        - firebase: []
      x-google-backend:
        address: "${function_url}"
        protocol: "http/1.1"
        
      responses:
        "200":
          description: "Translation successful"
          headers:
            Access-Control-Allow-Origin:
              type: "string"
securityDefinitions:
  firebase:
    type: "oauth2"
    flow: "implicit"
    authorizationUrl: "https://accounts.google.com/o/oauth2/auth"
    x-google-forwarding-header: "Authorization"
    x-google-issuer: "https://securetoken.google.com/micro-eye-455517-a2"
    x-google-jwks_uri: "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
    x-google-audiences: "micro-eye-455517-a2"
    scopes:
      openid: "OpenID scope"
      email: "Email scope"
      profile: "Profile scope"