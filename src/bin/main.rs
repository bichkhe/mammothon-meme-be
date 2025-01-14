use loco_rs::cli;
use mammothon_meme_be::app::App;

use std::{collections::BTreeMap, env};

use convex::ConvexClient;

#[tokio::main]
async fn main() -> loco_rs::Result<()> {
    dotenvy::from_filename(".env.local").ok();

    dotenvy::dotenv().ok();

    let deployment_url = env::var("CONVEX_URL").unwrap();

    let mut client = ConvexClient::new(&deployment_url).await.unwrap();
    let result = client.query("tasks:get", BTreeMap::new()).await.unwrap();
    println!("{result:#?}");

    cli::main::<App>().await
}
