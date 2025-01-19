use axum::{extract::Extension, routing::get};
use loco_rs::prelude::*;
use std::collections::BTreeMap;

use crate::errors::AppError;
use crate::views::{home::HomeResponse, task::TaskGetListResponse};
use convex::{ConvexClient, FunctionResult};

async fn get_tasks(
    Extension(mut db_client): Extension<ConvexClient>,
) -> Result<Response, AppError> {
    let task_query_result = db_client
        .query("tasks:get", BTreeMap::new())
        .await
        .map_err(|e| AppError::DbQuery {
            query: e.to_string(),
        })?;

    let query_value = match task_query_result {
        FunctionResult::Value(v) => v,
        FunctionResult::ErrorMessage(e) => {
            return Err(AppError::DbQuery { query: e });
        }
        FunctionResult::ConvexError(e) => {
            return Err(AppError::DbQuery {
                query: e.to_string(),
            });
        }
    };

    format::json(TaskGetListResponse::new(query_value, 0)).map_err(|e| AppError::ParseObject {
        reason: e.to_string(),
    })
}

async fn create_task(Extension(mut db_client): Extension<ConvexClient>) -> Result<Response> {
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
