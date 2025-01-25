use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct Task {
    #[serde(rename = "isCompleted")]
    pub is_completed: bool,

    #[serde(rename = "text")]
    pub text: String,
}
