use crate::{errors::AppError, models::tasks};
use convex::Value;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct TaskGetListResponse {
    pub page: Vec<tasks::Task>,

    #[serde(rename = "continueCursor")]
    pub continue_cursor: String,

    #[serde(rename = "splitCursor")]
    pub split_cursor: Option<String>,

    #[serde(rename = "pageStatus")]
    pub page_status: Option<String>,

    #[serde(rename = "isDone")]
    pub is_done: bool,
}

impl TaskGetListResponse {
    #[must_use]
    pub fn new(tasks_value: Value) -> Result<Self, AppError> {
        let task_json = tasks_value.export();
        let response: TaskGetListResponse =
            match serde_json::from_str(task_json.to_string().as_str()) {
                Ok(t) => t,
                Err(e) => {
                    println!("parse object failed {e:#?}");
                    return Err(AppError::ParseObject {
                        reason: e.to_string(),
                    });
                }
            };
        Ok(response)
    }
}
