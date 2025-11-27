use extendr_api::prelude::*;
use path_tree::PathTree;
use path_tree::Piece;
use path_tree::Position;

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

#[extendr]
/// Deconstruct a path pattern
///
/// This function parses a path pattern and returns both the name of the
/// parameters and a version of the path formatted for glue string
/// interpolation.
///
/// @param path The path pattern to parse
///
/// @return A list with the elements `keys` containing the names of all the path
/// parameters and `glue` containing a glue ready version of the path
///
/// @export
///
/// @examples
/// path_params("/users/:user/assets/*")
fn path_params(path: &str) -> Robj {
    let mut tree = PathTree::new();
    let id = tree.insert(path, 0);
    let mut keys: Vec<String> = Vec::new();
    let mut glue = String::new();
    for key in tree.get_route(id).unwrap().1.iter() {
        match key {
            Piece::Parameter(pos, _kind) => match pos {
                Position::Named(name) => {
                    keys.push(String::from_utf8(name.to_vec()).unwrap());
                    glue.push_str("{`");
                    glue.push_str(keys.last().expect("Unexpected error: keys vector should not be empty"));
                    glue.push_str("`}");
                }
                Position::Index(_ind, name) => {
                    keys.push(String::from_utf8(name.to_vec()).unwrap());
                    glue.push_str("{`");
                    glue.push_str(keys.last().expect("Unexpected error: keys vector should not be empty"));
                    glue.push_str("`}");
                }
            },
            Piece::String(str) => {
                glue.push_str(str::from_utf8(str).unwrap());
            }
        }
    }
    list!(keys = keys, glue = glue).into()
}

// Macro to generate exports.
extendr_module! {
    mod waysign;
    fn create_router;
    fn format_router;
    fn router_add_path;
    fn router_find_handler;
    fn count_paths;
    fn path_params;
}
