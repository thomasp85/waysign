use extendr_api::prelude::*;
use path_tree::PathTree;

#[extendr]
struct Router {
    path_tree: PathTree<String>,
}

#[extendr]
fn create_router() -> Router {
    Router {
        path_tree: PathTree::new(),
    }
}

#[extendr]
fn format_router(router: ExternalPtr<Router>) -> String {
    format!("{:?}", router.path_tree)
}

#[extendr]
fn router_add_path(mut router: ExternalPtr<Router>, path: &str, id: &str) {
    let _ = router.path_tree.insert(path, id.to_string());
}

#[extendr]
fn router_find_handler(router: ExternalPtr<Router>, path: &str) -> Robj {
    match router.path_tree.find(path) {
        Some((id, params)) => {
            let mut keys: Vec<String> = Vec::new();
            let mut values: Vec<String> = Vec::new();

            for (key, value) in params.params_iter() {
                keys.push(key.to_string());
                values.push(value.to_string());
            }

            // Create R list
            list!(id = id.as_str(), keys = keys, values = values).into()
        }
        None => ().into(),
    }
}

// Macro to generate exports.
extendr_module! {
    mod waysign;
    fn create_router;
    fn format_router;
    fn router_add_path;
    fn router_find_handler;
}
