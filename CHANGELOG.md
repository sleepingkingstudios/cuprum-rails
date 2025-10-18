# Changelog

## O.3.0

Dropped support for Rails 6.X.

### Actions

Split out actions into Action classes (handling parameter validation, parameter mapping, and response generation) and Command classes (business logic).

- Updated `Action` to wrap either a block or an instance of `Cuprum::Rails::Command`.
- Implemented `Actions::Resources` to wrap the new `Commands::Resources` commands or custom commands implementing a resourceful action.
- Deprecated `Action.build` in favor of `Action.subclass`.
- Deprecated the following existing implementations:
  - `Actions::Create`.
  - `Actions::Destroy`.
  - `Actions::Edit`.
  - `Actions::Index`.
  - `Actions::New`.
  - `Actions::Show`.
  - `Actions::Update`.

### Commands

Implemented `Cuprum::Rails::Command` as an abstract base class for action-compatible business logic. Commands take optional `:resource` and `:repository` keyword parameters.

- Implemented `Commands::Resources` to implement resourceful CRUD actions for plural or singular resources.

### Controllers

- Updated controller actions to return the response object.

#### Middleware

- Updated syntax for `Controller.middleware()`. Instead of passing `only:` and `except:` keywords directly to filter middleware by action name, pass them in an `actions: { except:, only: }` Hash. You can also define using a shorthand: `actions: :index` or `actions: %w[new edit update destroy]`.
- `Controller.middleware()` now supports filtering by request format by passing a `formats:` keyword. You can pass a single format, an array of formats, or a Hash with `except:` and/or `only:` keys.

### Records

Refactored the existing collection to `Cuprum::Rails::Records::Collection`.

- Refactor `Collection` to `Records::Collection`. Creating a `Cuprum::Rails::Collection` will print a deprecation warning.
- Refactor `Repository` to `Records::Repository`. Creating a `Cuprum::Rails::Repository` will print a deprecation warning.
- Refactor `Query` to `Records::Query`. Creating a `Cuprum::Rails::Query` will print a deprecation warning.
- **Breaking Change**: Refactor `Command` to `Records::Command`.
- **Breaking Change**: Refactor `Commands` to `Records::Commands`.
- **Breaking Change**: Refactor `Scopes` to `Records::Scopes`.

### Responders

Added support for Turbo Frames when rendering HTML content.

### Responses

Implemented `Cuprum::Rails::Responses::HtmlResponse`, implementing `render html: ''`.

### RSpec

Extracted `Cuprum::Rails::RSpec::Deferred::Responses`, with support for HTML and JSON responses.

- Can now use the `Responses` deferred examples for testing controllers as well as responders.
- Existing responder specs should include the relevante response examples and define an explicit `let(:response)` helper.

## O.2.0

### Actions

Implemented `#transaction` method.

Refactored how actions handle required parameters.

- The validation errors for the `Create` and `Update` actions are now scoped by the resource name. The error path should now match the relative path of the corresponding form field.

- **(Breaking Change)** Action constructors no longer accept `:repository` or `:resource` keywords by default.

- **(Breaking Change)** Actions now require a `:repository` keyword when called, and can accept arbitrary keywords.

- **(Breaking Change)** Resource actions now require a `:resource` keyword when called.

#### Middleware

- Defined `Actions::Middleware::Associations::Find` for querying associations.
- Defined `Actions::Middleware::Associations::Parent` for querying a parent `belongs_to` association.
- Defines `Actions::Middleware::LogRequest` for logging request details.
- Defines `Actions::Middleware::LogResult` for logging the action result.

### Collections

Implemented `Collection#qualified_path`, and added qualified path support to `Repository`.

#### Commands

Commands now handle invalid SQL statement exceptions by returning a failing result with a `StatementInvalid` error, rather than raising the exception.

### Controllers

Implemented `.build_request` class method.

Implemented `.default_format` configuration option.

Refactored `Cuprum::Rails::ControllerAction` to `Cuprum::Rails::Controllers::Action`.

- **(Breaking Change)** Controller actions now require a `:controller` argument when called.

#### Middleware

Implemented controller middleware.

- `Cuprum::Rails::Controllers::Middleware`.
- `Cuprum::Rails::Controllers::ClassMethods::Middleware`.

Updated `Cuprum::Rails::Controllers::Action` to apply configured middleware.

#### Requests

Added `#context` method to access the original request controller or context.

Added `#member_action?` method to identify requests to resourceful member actions.

Added `#native_session` method to lazily access the native controller session.

Added `#properties` method to access all request properties as a Hash.

Added `#path_params` method and properly handle parameters from the request path.

**(Breaking Change)** Renamed `#method` property to `#http_method`.

#### Resources

Automatically generate a `Cuprum::Rails::Collection` when creating a resource with a `record_class` but no explicit `collection`.

Added `#actions` option, which is automatically generated for singular and plural resources.

Added `#parent` option and associated `#ancestors` and `#each_ancestors` methods.

- **(Breaking Change)** Removed `Resource#collection`.

#### Responders

Implemented `Responders::Html::Resource` to handle both singular and plural resources.

- `Cuprum::Rails::Responders::Html::PluralResource` is now deprecated.
- `Cuprum::Rails::Responders::Html::SingularResource` is now deprecated.

Updated `JsonResponder` to display full error messages in the development environment.

Extracted `Responders::BaseResponder`.

Extracted `Responders::Html::Rendering`.

**(Breaking Change)** Responders now require `:controller` and `:request` parameters on initialization.

#### Responses

Implemented `Responses::HeadResponse`.

Implemented `Responses::Html::RedirectBackResponse`.

Added Rails flash message support to HTML responses:

- `Responses::Html::RedirectBackResponse`.
- `Responses::Html::RedirectResponse`.
- `Responses::Html::RenderResponse`.

### Results

Implemented `Cuprum::Rails::Result`, which includes a `#metadata` property for passing contextual data such as an authentication session or page configuration.

### Routes

Route helpers not accept a wildcards hash for populating route wildcards, as an alternative to calling `routes.with_wildcards`.

Member route methods now accept a primary key value as well as an entity, or allow the key to be passed as part of the wildcards.

### RSpec

Implemented contracts for Cuprum::Rails actions:

- `Cuprum::Rails::RSpec::Contracts::Actions::CreateContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::DestroyContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::EditContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::IndexContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::NewContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::ShowContracts`
- `Cuprum::Rails::RSpec::Contracts::Actions::UpdateContracts`

Contracts allow libraries or applications to verify their actions implement the action specifications.

Defined `Cuprum::Rails::RSpec::Contracts::SerializersContracts`:

- `ShouldSerailizeAttributesContract`: Verifies that the specified attributes are serialized with the expected values.

Implemented `Cuprum::Rails::RSpec::Matchers::BeAResultMatcher`, which adds support for a `#metadata` property to the `be_a_result` matcher.

- **(Breaking Change)** Existing contracts were moved into the `Cuprum::Rails::RSpec::Contracts` namespace and are scoped by type.
  - `COMMAND_CONTRACT` is now `Contracts::CommandContracts::ShouldBeARailsCommandContract`.
  - `DEFINE_ROUTE_CONTRACT` is replaced with `Contracts::RoutesContracts::ShouldDefineCollectionRouteContract` and `ShouldDefineMemberRouteContract`.

### Serializers

Implemented `Cuprum::Rails::Serializers::Context`.

- Refactored serializers to take a `context:` keyword instead of `serializers:`.

Implemented `Cuprum::Rails::Serializers::Json::PropertiesSerializer`.

- Refactored `AttributesSerializer` to inherit from `PropertiesSerializer`. This is a breaking change for certain serializers with a block passed to `.attribute`.

## 0.1.0

Initial version.

### Collections

Implemented `Cuprum::Rails::Collection`.

Implemented `Cuprum::Rails::Repository`.

#### Commands

Implemented `Cuprum::Rails::Command`.

Implemented Rails collection commands:

- `Cuprum::Rails::Commands::AssignOne`.
- `Cuprum::Rails::Commands::BuildOne`.
- `Cuprum::Rails::Commands::DestroyOne`.
- `Cuprum::Rails::Commands::FindMany`.
- `Cuprum::Rails::Commands::FindMatching`.
- `Cuprum::Rails::Commands::FindOne`.
- `Cuprum::Rails::Commands::InsertOne`.
- `Cuprum::Rails::Commands::UpdateOne`.
- `Cuprum::Rails::Commands::ValidateOne`.

### Controllers

Implemented `Cuprum::Rails::Controller`.

Implemented `Cuprum::Rails::ControllerAction`.

Implemented `Cuprum::Rails::Controllers::Configuration`.

#### Actions

Implemented `Cuprum::Rails::Action`.

Implemented `Cuprum::Rails::Actions::ResourceAction`.

Implemented resourceful actions:

- `Cuprum::Rails::Actions::Create`.
- `Cuprum::Rails::Actions::Destroy`.
- `Cuprum::Rails::Actions::Edit`.
- `Cuprum::Rails::Actions::Index`.
- `Cuprum::Rails::Actions::New`.
- `Cuprum::Rails::Actions::Show`.
- `Cuprum::Rails::Actions::Update`.

#### Requests

Implemented `Cuprum::Rails::Request`.

#### Resources

Implemented `Cuprum::Rails::Resource`.

#### Responders

Implemented responders:

- `Cuprum::Rails::Responders::HtmlResponder`.
- `Cuprum::Rails::Responders::Html::PluralResource`.
- `Cuprum::Rails::Responders::Html::SingularResource`.
- `Cuprum::Rails::Responders::JsonResponder`.
- `Cuprum::Rails::Responders::Json::Resource`.

#### Responses

Implemented responses:

- `Cuprum::Rails::Responses::Html::RedirectResponse`
- `Cuprum::Rails::Responses::Html::RenderResponse`
- `Cuprum::Rails::Responses::JsonResponse`

#### Routes

Implemented `Cuprum::Rails::Routes`.

Implemented resourceful routes:

- `Cuprum::Rails::Routing::PluralRoutes`.
- `Cuprum::Rails::Routing::SingularRoutes`.

#### Serializers

Implemented JSON serializers:

- `Cuprum::Rails::Serializers::Json::ActiveRecordSerializer`.
- `Cuprum::Rails::Serializers::Json::ArraySerializer`.
- `Cuprum::Rails::Serializers::Json::AttributesSerializer`.
- `Cuprum::Rails::Serializers::Json::ErrorSerializer`.
- `Cuprum::Rails::Serializers::Json::HashSerializer`.
- `Cuprum::Rails::Serializers::Json::IdentitySerializer`.
- `Cuprum::Rails::Serializers::Json::Serializer`.
