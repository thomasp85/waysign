use extendr_api::prelude::*;
use path_tree::PathTree;

#[extendr]
struct WaysignRouter {
    path_tree: PathTree<String>,
}

#[extendr]
fn create_router() -> WaysignRouter {
    WaysignRouter {
        path_tree: PathTree::new(),
    }
}

#[extendr]
fn format_router(router: ExternalPtr<WaysignRouter>) -> String {
    format!("{:?}", router.path_tree)
}

#[extendr]
fn count_paths(router: ExternalPtr<WaysignRouter>) -> i32 {
    router.path_tree.iter().fold(0, |acc, _x| acc + 1)
}

#[extendr]
fn router_add_path(mut router: ExternalPtr<WaysignRouter>, path: &str, id: &str) {
    let _ = router.path_tree.insert(path, id.to_string());
}

#[extendr]
fn router_find_handler(router: ExternalPtr<WaysignRouter>, path: &str) -> Robj {
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
    fn count_paths;
}
