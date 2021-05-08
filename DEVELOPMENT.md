# Development

## Action

### Resourceful Actions

- create
- destroy
- edit
- index
- new
- show
- update

## Controller

### DSL

```ruby
class ExampleController
  # Pass the result to the default responder.
  action :create, Example::Actions::Create

  # Handle custom responses.
  action :custom, Example::Actions::Custom do |result|
    CustomResponder.call(resource: resource, result: result)
  end
end
```

## Resource

- base_url
- collection
- default_order
- permitted_attributes
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

### SingularRoutes

### PluralRoutes

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
