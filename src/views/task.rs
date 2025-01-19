use crate::models::tasks;
use convex::Value;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct TaskGetListResponse {
    pub items: Vec<tasks::Task>,
    pub total: u64,
}

impl TaskGetListResponse {
    #[must_use]
    pub fn new(convex_value: Value, total: u64) -> Self {
        let items: Vec<tasks::Task> = match convex_value {
            Value::Array(list) => {
                let list: Vec<tasks::Task> = list
                    .into_iter()
                    .map(|v| {
                        let task_json = v.export();
                        let task: tasks::Task =
                            match serde_json::from_str(task_json.to_string().as_str()) {
                                Ok(t) => t,
                                Err(e) => {
                                    println!("parse object failed {e:#?}");
                                    tasks::Task::default()
                                }
                            };
                        task
                    })
                    .collect();
                list
            }
            _ => vec![],
        };
        Self { items, total }
    }
}
