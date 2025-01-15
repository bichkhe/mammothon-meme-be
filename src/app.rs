use async_trait::async_trait;
use axum::extract::Extension;
use axum::Router as AxumRouter;

use loco_rs::{
    app::{AppContext, Hooks, Initializer},
    bgworker::Queue,
    boot::{create_app, BootResult, StartMode},
    controller::AppRoutes,
    environment::Environment,
    task::Tasks,
    Result,
};
use std::env;

use convex::ConvexClient;

use crate::controllers;

pub struct App;
#[async_trait]
impl Hooks for App {
    fn app_name() -> &'static str {
        env!("CARGO_CRATE_NAME")
    }

    fn app_version() -> String {
        format!(
            "{} ({})",
            env!("CARGO_PKG_VERSION"),
            option_env!("BUILD_SHA")
                .or(option_env!("GITHUB_SHA"))
                .unwrap_or("dev")
        )
    }

    async fn boot(mode: StartMode, environment: &Environment) -> Result<BootResult> {
        create_app::<Self>(mode, environment).await
    }

    async fn initializers(_ctx: &AppContext) -> Result<Vec<Box<dyn Initializer>>> {
        Ok(vec![])
    }

    fn routes(_ctx: &AppContext) -> AppRoutes {
        AppRoutes::with_default_routes() // controller routes below
            .add_route(controllers::home::routes())
    }
    async fn connect_workers(_ctx: &AppContext, _queue: &Queue) -> Result<()> {
        Ok(())
    }
    fn register_tasks(_tasks: &mut Tasks) {
        // tasks-inject (do not remove)
    }

    async fn after_routes(mut router: AxumRouter, _ctx: &AppContext) -> Result<AxumRouter> {
        // use AxumRouter to mount your routes and return an AxumRouter
        dotenvy::from_filename(".env.local").ok();
        dotenvy::dotenv().ok();

        let deployment_url = env::var("CONVEX_URL").unwrap();
        let client = ConvexClient::new(&deployment_url).await.unwrap();
        router = router.layer(Extension(client));
        Ok(router)
    }
}
