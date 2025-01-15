use axum::debug_handler;
use axum::{extract::Extension, routing::get};
use loco_rs::prelude::*;
use std::collections::BTreeMap;

use crate::views::home::HomeResponse;
use convex::ConvexClient;

async fn create_user(Extension(mut db_client): Extension<ConvexClient>) -> Result<Response> {
    let result = db_client.query("tasks:get", BTreeMap::new()).await.unwrap();
    println!("{result:#?}");
    format::json(HomeResponse::new("loco"))
}

#[debug_handler]
async fn current() -> Result<Response> {
    format::json(HomeResponse::new("loco"))
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("/api")
        .add("/", get(current))
        .add("/create_user", get(create_user))
}
