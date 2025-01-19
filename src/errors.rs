use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde_json::json;
use snafu::Snafu;

#[derive(Debug, Snafu)]
pub enum AppError {
    #[snafu(display("A db query error occurred: {}", query))]
    DbQuery { query: String },

    #[snafu(display("A parse object error occurred: {}", reason))]
    ParseObject { reason: String },

    #[snafu(display("An unknown error occurred"))]
    Unknown,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let status_code = match self {
            AppError::DbQuery { .. } => StatusCode::INTERNAL_SERVER_ERROR,
            AppError::ParseObject { .. } => StatusCode::BAD_REQUEST,
            AppError::Unknown => StatusCode::INTERNAL_SERVER_ERROR,
        };

        let body = axum::Json(json!({ "error": self.to_string() }));
        (status_code, body).into_response()
    }
}
