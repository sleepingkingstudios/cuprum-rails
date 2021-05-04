# Development

## Action

\#call takes parameters:

- cookies: ActionDispatch::Cookies::CookieJar
- headers: Hash
- params:  ActionController::Parameters

### Resourceful Actions

- create
- destroy
- edit
- index
- new
- show
- update

## Resource

- plural?
- plural_resource_name
- resource_class
- resource_name
- routes (an instance of Routes, below)
- scope
  - defaults to {}
  - for nested resources, primary_keys
    e.g. { project_id: value }
- singular?
- singular_resource_name

### Routes

- edit_path(resource)
- index_path
- new_path
- show_path(resource)

Curries scoped resources:
  project_tasks_path(project) => tasks(project).routes.index_path

## Responder

- on failure, determine status code
- only display whitelisted errors in response

### HtmlResponder

- generic collection action
  - on success, assign data.keys and render action
  - on failure, redirect to parent_scope (defaults to root)
- generic member action
  - on success, assign data.keys and render action
  - on failure, redirect to collection scope

### JsonResponder
