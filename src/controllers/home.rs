use axum::{
    extract::{Extension, Query},
    routing::get,
};
use loco_rs::prelude::*;
use std::collections::BTreeMap;

use crate::errors::AppError;
use crate::views::{home::HomeResponse, tasks::TaskGetListResponse};
use convex::{ConvexClient, FunctionResult, Value};
use serde::Deserialize;

#[derive(Deserialize)]
struct TaskQueryParams {
    limit: Option<f64>,
    cursor: Option<String>,
    is_completed: Option<bool>,
    text: Option<String>,
}

async fn get_tasks(
    Extension(mut db_client): Extension<ConvexClient>,
    Query(params): Query<TaskQueryParams>,
) -> Result<Response, AppError> {
    let mut filter = BTreeMap::new();
    let mut query_input = BTreeMap::new();
    let mut pagination = BTreeMap::new();

    if let Some(limit) = params.limit {
        pagination.insert("limit".to_string(), Value::Float64(limit));
    }

    if let Some(cursor) = params.cursor {
        pagination.insert("cursor".to_string(), Value::String(cursor));
    }

    if let Some(is_completed) = params.is_completed {
        filter.insert("is_completed".to_string(), Value::Boolean(is_completed));
    }

    if let Some(text) = params.text {
        filter.insert("text".to_string(), Value::String(text));
    }

    query_input.insert("queryFilter".to_string(), Value::Object(filter.clone()));
    query_input.insert("pagination".to_string(), Value::Object(pagination.clone()));

    let task_query_result = db_client
        .query("tasks:get", query_input)
        .await
        .map_err(|e| AppError::DbQuery {
            query: e.to_string(),
        })?;

    println!("task query: {:?}", task_query_result);
    let query_value = convert_func_result_to_value(task_query_result)?;

    let resp = TaskGetListResponse::new(query_value)?;
    format::json(resp).map_err(|e| AppError::ParseObject {
        reason: e.to_string(),
    })
}

async fn create_task(Extension(mut _db_client): Extension<ConvexClient>) -> Result<Response> {
    // let task = BTreeMap::new();
    // let result = db_client
    //     .mutation(
    //         "tasks:create"
    //     )
    //     .await?;
    // println!("{result:#?}");
    format::json(HomeResponse::new("loco"))
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("/api")
        .add("/get_tasks", get(get_tasks))
        .add("/create_task", post(create_task))
}

fn convert_func_result_to_value(result: FunctionResult) -> Result<convex::Value, AppError> {
    match result {
        FunctionResult::Value(v) => Ok(v),
        FunctionResult::ErrorMessage(e) => Err(AppError::DbQuery { query: e }),
        FunctionResult::ConvexError(e) => Err(AppError::DbQuery {
            query: e.to_string(),
        }),
    }
}
