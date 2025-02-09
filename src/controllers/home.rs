use axum::{
    body::Body, extract::{Extension, Query}, routing::get
};
use loco_rs::{prelude::*, validator::ValidateLength};
use serde_json::Error;
use std::{collections::BTreeMap, string};

use crate::errors::AppError;
use crate::views::{home::HomeResponse, tasks::TaskGetListResponse};
use convex::{ConvexClient, FunctionResult, Value};
use serde::{Deserialize, Serialize};
use celestia_rpc::{BlobClient, Client, TxConfig};
use celestia_types::{nmt::Namespace, AppVersion, Blob};

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
        .add("/test", get(test))
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
async fn test() -> Result<Response, AppError> {
    let data = submit_blob("http://localhost:26658", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJwdWJsaWMiLCJyZWFkIiwid3JpdGUiLCJhZG1pbiJdfQ.bgPSpSLYdLzA5bgx-PY9VfjWdnRGsQVWhGAvP4LT1J8").await;
    format::json(data).map_err(|e| AppError::ParseObject {
        reason: e.to_string(),
    })
}
async fn submit_blob(url: &str, token: &str) -> Option<String>{
    let client = Client::new(url, if token == "" { None } else { Some(token) })
        .await
        .expect("Failed creating rpc client");

    // create a blob that you want to submit
    let my_namespace = Namespace::new_v0(&[1, 2, 3, 4, 5]).expect("Invalid namespace");
    let blob = Blob::new(my_namespace, b"some data to store on blockchain".to_vec(), AppVersion::V1)
        .expect("Failed to create a blob");

    // submit it
    let height = client.blob_submit(&[blob], TxConfig::default())
        .await
        .expect("Failed submitting the blob");
    // fetch the blob back from the network
    print!("Fetching the blob back from the network...");
        if let Some(retrieved_blobs) = client.blob_get_all(height, &[my_namespace]).await.expect("Failed to retrieve blobs") {
            if retrieved_blobs.len() == 1 {
                let retrieved_blob = &retrieved_blobs[0];
                print!("received data: {}" , String::from_utf8(retrieved_blob.data.clone()).expect("invalid string, cant convert"));
                // Verify data consistency
                assert_eq!(retrieved_blob.data, b"some data to store on blockchain");
    
                return Some(hex::encode(retrieved_blob.commitment.hash()));
            }
        }
        None
}
