# Changelog

## O.2.0

### Actions

Implemented `#transaction` method.

Refactored how actions handle required parameters.

### Collections

Implemented `Collection#qualified_path`, and added qualified path support to `Repository`.

### Controllers

Implemented `.build_request` class method.

Implemented `.default_format` configuration option.

Refactored `Cuprum::Rails::ControllerAction` to `Cuprum::Rails::Controllers::Action`.

#### Middleware

Implemented controller middleware.

- `Cuprum::Rails::Controllers::Middleware`.
- `Cuprum::Rails::Controllers::ClassMethods::Middleware`.

Updated `Cuprum::Rails::Controllers::Action` to apply configured middleware.

#### Requests

Added `#context` method to access the original request controller or context.

Added `#native_session` method to lazily access the native controller session.

Added `#properties` method to access all request properties as a Hash.

Added `#path_params` method and properly handle parameters from the request path.

**(Breaking Change)** Renamed `#method` property to `#http_method`.

#### Resources

Automatically generate a `Cuprum::Rails::Collection` when creating a resource with a `record_class` but no explicit `collection`.

#### Responders

Implemented `Responders::Html::Resource` to handle both singular and plural resources.

- `Cuprum::Rails::Responders::Html::PluralResource` is now deprecated.
- `Cuprum::Rails::Responders::Html::SingularResource` is now deprecated.

Updated `JsonResponder` to display full error messages in the development environment.

Extracted `Responders::BaseResponder`.

Extracted `Responders::Html::Rendering`.

**(Breaking Change)** Responders now require a `:controller_name` parameter on initialization. This populates the `#controller_name` reader with the name of the initializing controller.

#### Responses

Implemented `Responses::HeadResponse`.

Implemented `Responses::Html::RedirectBackResponse`.

#### RSpec

Implemented contracts for Cuprum::Rails actions

- `Cuprum::Rails::RSpec::Actions::CreateContracts`
- `Cuprum::Rails::RSpec::Actions::DestroyContracts`
- `Cuprum::Rails::RSpec::Actions::EditContracts`
- `Cuprum::Rails::RSpec::Actions::IndexContracts`
- `Cuprum::Rails::RSpec::Actions::NewContracts`
- `Cuprum::Rails::RSpec::Actions::ShowContracts`
- `Cuprum::Rails::RSpec::Actions::UpdateContracts`

Contracts allow libraries or applications to verify their actions implement the action specifications.

Defined `Cuprum::Rails::RSpec::SerializersContracts`:

- `SHOULD_SERIALIZE_ATTRIBUTES`: Verifies that the specified attributes are serialized with the expected values.

#### Serializers

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
