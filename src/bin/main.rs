use loco_rs::cli;
use mammothon_meme_be::app::App;

#[tokio::main]
async fn main() -> loco_rs::Result<()> {
    // let result = client.query("tasks:get", BTreeMap::new()).await.unwrap();
    // println!("{result:#?}");

    cli::main::<App>().await
}
