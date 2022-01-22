# Cuprum::Rails

An integration between Rails and the Cuprum library.

Cuprum::Rails defines the following objects:

- [Collections](#collections): A collection for performing operations on ActiveRecord models using the standard `Cuprum::Collections` interface.
    - [Commands](#commands): Each collection is comprised of `Cuprum` commands, which implement common collection operations such as inserting or querying data.
- [Controllers](#controllers): Decouples controller responsibilities for precise control, reusability, and reduction of boilerplate code.
    - [Actions](#actions): Implement a controller's actions as a `Cuprum` command.
    - [Middleware](#middleware): Wraps a controller's actions with additional functionality.
    - [Requests](#requests): Encapsulates a controller request.
    - [Resources](#resources) and [Routes](#routes): Configuration for a resourceful controller.
    - [Responders](#responders) and [Responses](#responses): Generate controller responses from action results.
    - [Serializers](#serializers): Recursively convert entities and data structures into serialized data.

## About

Cuprum::Rails provides a toolkit for using the Cuprum command pattern and the flexibility of Cuprum::Collections to build Rails applications. Using the `Cuprum::Rails::Collection`, you can perform operations on ActiveRecord models, leveraging a standard interface to control where your data is stored and how it is queried. For example, you can inject a mock collection into unit tests for precise control over queried values and blinding fast tests without having to hit the database directly.

Using `Cuprum::Rails::Controller` takes this one step further, breaking apart the traditional controller into a sequence of steps with individual responsibilities. This has two main benefits. First, being explicit about how your controllers perform and respond to actions allows for precise control at each step of the process. Second, each step is encapsulated, which allows for easier testing and reuse. This not only makes testing simpler - you can test your business logic by examining an Action result, rather than parsing a rendered HTML page - but allows you to reuse individual components. The goal is to reduce the boilerplate inherent in writing a Rails application by allowing you to define only the code that is unique to the controller, action, or process.

### Why Cuprum::Rails?

Rails is a highly opinionated framework: one of the pillars of The Rails Doctrine is the principle that "The menu is omakase". This is one of the keys to the framework's success, providing a welcoming environment for new developers as well as powerful tools for developing applications - as long as those applications are built The Rails Way.

This is great for rapidly developing prototypes, proof of concept or proof of market applications, or even smaller applications for content management, e-commerce, and so on. There are good reasons why Rails has made so much headway against established behemoths such as WordPress. That being said, many companies are using Rails to build applications that are much more ambitious, and at that scale the standard Rails patterns start to fall apart. Omakase is no longer just right.

Cuprum::Rails is intended to address two of the pain points of Big Rails. The first is architectural: any Rails developer of a certain age will remember the wars over Fat Controllers versus Fat Models. The rise of Service Objects provides a way forward, but in practice this can be something of a Wild West - everything gets dumped in an `app/services` directory, each file looks and works differently. The [Cuprum](github.com/sleepingkingstudios/cuprum) gem is designed to provide a solution to this chaos. Defining a command gives you the benefits of encapsulation, control flow, and *consistency* - every command defines one `#call` method and returns a result.

The second benefit is *reusability*. Breaking down a controller into its constituent steps means you don't have to reimplement each of those steps each time you create a controller or add an action. You can define what it means to respond to an HTML or JSON request once, and modify it on a per-action basis when you need custom behavior. You can subclass the resourceful action commands to leverage basic controller functionality, such as performing filtered queries. And, of course, you gain all the benefits of decoupling commands from your controller - you can use the same functionality in a controller action, as an asynchronous job, or as a command-line function.

### Compatibility

Cuprum::Rails is tested against Ruby (MRI) 2.6 through 3.1, and Rails 6.0 through 7.0.

### Documentation

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2021-2022 Rob Smith

Stannum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum-rails.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum-rails/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum-rails/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Code of Conduct

Please note that the `Cuprum::Collections` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/cuprum-rails/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

<!-- ## Getting Started  -->

## Reference

<a id="collections"></a>

### Collections

```ruby
require 'cuprum/rails/collection'
```

A `Cuprum::Rails::Collection` implements the [Cuprum::Collections](https://github.com/sleepingkingstudios/cuprum-collections) interface for `ActiveRecord` models. It defines a set of [commands](#commands) that implement persistence and query operations, and a `#query` method to directly perform queries on the data.

```ruby
collection = Cuprum::Rails::Collection.new(record_class: Book)

# Add an item to the collection.
steps do
  # Build the book from attributes.
  book = step do
    collection.build_one.call(
      attributes: { id: 10, title: 'Gideon the Ninth', author: 'Tamsyn Muir' }
    )
  end

  # Validate the book using its default validations.
  step { collection.validate_one.call(entity: book) }

  # Insert the validated book to the collection.
  step { collection.insert_one.call(entity: book) }
end

# Find an item by primary key.
book = step { collection.find_one.call(primary_key: 10) }

# Find items matching a filter.
books = step do
  collection.find_matching.call(
    limit: 10,
    order: [:author, { title: :descending }],
    where: lambda do
      published_at: greater_than('1950-01-01')
    end
  )
end
```

Initializing a collection requires the `:record_class` keyword, which should be a Class that inherits from `ActiveRecord::Base`. You can also specify some optional keywords:

- The `:collection_name` parameter sets the name of the collection. It is used to create an envelope for query commands, such as the `FindMany`, `FindMatching` and `FindOne` commands.
- The `:default_contract` parameter sets a default contract for validating collection entities. If no `:contract` keyword is passed to the `ValidateOne` command, it will use the default contract to validate the entity instead of the validation constraints defined for the model.
- The `:member_name` parameter is used to create an envelope for singular query commands such as the `FindOne` command. If not given, the member name will be generated automatically as a singular form of the collection name.
- The `:primary_key_name` parameter specifies the attribute that serves as the primary key for the collection entities. The default value is `:id`.
- The `:primary_key_type` parameter specifies the type of the primary key attribute. The default value is `Integer`.

<a id="commands"></a>

#### Commands

Structurally, a collection is a set of commands, which are instances of `Cuprum::Command` that implement a persistence or querying operation and wrap that operation with parameter validation and error handling. For more information on Cuprum commands, see the [Cuprum gem](github.com/sleepingkingstudios/cuprum).

##### Assign One

The `AssignOne` command takes an attributes hash and a record, assigns the given attributes to the record, and returns the record.

```ruby
book       = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
attributes = { 'title' => 'Harrow the Ninth', 'published_at' => '2020-08-04' }
result     = collection.assign_one.call(attributes: attributes, entity: entity)

result.value.class
#=> Book
result.value.attributes
#=> {
#     'id'           => 10,
#     'title'        => 'Harrow the Ninth',
#     'author'       => 'Tamsyn Muir',
#     'series'       => nil,
#     'category'     => nil,
#     'published_at' => '2020-08-04'
#   }
```

If the attributes hash includes one or more attributes that are not defined for that record class, the `#assign_one` command can return a failing result with an `ExtraAttributes` error.

##### Build One

The `BuildOne` command takes an attributes hash and returns a new record whose attributes are equal to the given attributes. This does not validate or persist the record; it is equivalent to calling `record_class.new` with the attributes.

```ruby
attributes = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir' }
result     = collection.build_one.call(attributes: attributes, entity: entity)

result.value.class
#=> Book
result.value.attributes
#=> {
#     'id'           => 10,
#     'title'        => 'Gideon the Ninth',
#     'author'       => 'Tamsyn Muir',
#     'series'       => nil,
#     'category'     => nil,
#     'published_at' => nil
#   }
```

If the attributes hash includes one or more attributes that are not defined for that record class, the `#build_one` command can return a failing result with an `ExtraAttributes` error.

##### Destroy One

The `DestroyOne` command takes a primary key value and removes the record with the specified primary key from the collection.

```ruby
result = collection.destroy_one.call(primary_key: 0)

collection.query.where(id: 0).exists?
#=> false
```

If the collection does not include a record with the specified primary key, the `#destroy_one` command will return a failing result with a `NotFound` error.

##### Find Many

The `FindMany` command takes an array of primary key values and returns the records with the specified primary keys. The entities are returned in the order of the specified primary keys.

```ruby
result = collection.find_many.call(primary_keys: [0, 1, 2])
result.value
#=> [
#     #<Book
#       id:           0,
#       title:        'The Hobbit',
#       author:       'J.R.R. Tolkien',
#       series:       nil,
#       category:     'Science Fiction and Fantasy',
#       published_at: '1937-09-21'
#     >,
#     #<Book
#       id:           1,
#       title:        'The Silmarillion',
#       author:       'J.R.R. Tolkien',
#       series:       nil,
#       category:     'Science Fiction and Fantasy',
#       published_at: '1977-09-15'
#     >,
#     #<Book
#       id:           2,
#       title:        'The Fellowship of the Ring',
#       author:       'J.R.R. Tolkien',
#       series:       'The Lord of the Rings',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1954-07-29'
#     >
#   ]
```

The `FindMany` command has several options:

- The `:allow_partial` keyword allows the command to return a passing result if at least one of the entities is found. By default, the command will return a failing result unless an entity is found for each primary key value.
- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_many.call(primary_keys: [0, 1, 2], envelope: true)
    result.value
    #=>  { books: [#<Book>, #<Book>, #<Book>] }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_many`.

If the collection does not include an entity with each of the specified primary keys, the `#find_many` command will return a failing result with a `NotFound` error.

##### Find Matching

The `FindMatching` command takes a set of query parameters and queries data from the collection. You can specify filters using the `:where` keyword or by passing a block, sort the results using the `:order` keyword, or return a subset of the results using the `:limit` and `:offset` keywords. For full details on performing queries, see [Queries](#queries), below.

```ruby
result =
  collection
  .find_matching
  .call(order: :published_at, where: { series: 'Earthsea' })
result.value
#=> [
#     #<Book
#       id:           7,
#       title:        'A Wizard of Earthsea',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1968-11-01'
#     >,
#     #<Book
#       id:           8,
#       title:        'The Tombs of Atuan',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1970-12-01'
#     >,
#     #<Book
#       id:           9,
#       title:        'The Farthest Shore',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1972-09-01'
#     >
#   ]
```

The `FindMatching` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_matching.call(where: { series: 'Earthsea' }, envelope: true)
    result.value
    #=>  { books: [#<Book>, #<Book>, #<Book>] }
    ```

- The `:limit` keyword caps the number of results returned.
- The `:offset` keyword skips the specified number of results.
- The `:order` keyword specifies the order of results.
- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_matching`.
- The `:where` keyword defines filters for which results are to be returned.

##### Find One

The `FindOne` command takes a primary key value and returns the record with the specified primary key.

```ruby
result = collection.find_one.call(primary_key: 1)
result.value
#=> #<Book
#     id:           1,
#     title:        'The Silmarillion',
#     author:       'J.R.R. Tolkien',
#     series:       nil,
#     category:     'Science Fiction and Fantasy',
#     published_at: '1977-09-15'
#   >
```

The `FindOne` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the singular name of the collection and whose value is the returned record.

    ```ruby
    result = collection.find_one.call(primary_key: 1, envelope: true)
    result.value
    #=>  { book: #<Book> }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only an entity that match the given scope will be found and returned by `#find_one`.

If the collection does not include a record with the specified primary key, the `#find_one` command will return a failing result with a `NotFound` error.

##### Insert One

The `InsertOne` command takes a record and inserts that record into the collection.

```ruby
book       = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
result     = collection.insert_one.call(entity: book)

result.value
#=> #<Book
#     id:           10,
#     title:        'Gideon the Ninth',
#     author:       'Tamsyn Muir',
#     series:       nil,
#     category:     nil,
#     published_at: nil
#   >

collection.query.where(id: 10).exists?
#=> true
```

If the collection already includes a record with the specified primary key, the `#insert_one` command will return a failing result with an `AlreadyExists` error.

##### Update One

The `UpdateOne` command takes a record and updates the corresponding record in the collection.

```ruby
book   = collection.find_one.call(1).value
book   = book.assign_attributes('author' => 'John Ronald Reuel Tolkien')
result = collection.update_one(entity: book)

result.value
#=> #<Book
#     id:           1,
#     title:        'The Silmarillion',
#     author:       'J.R.R. Tolkien',
#     series:       nil,
#     category:     'Science Fiction and Fantasy',
#     published_at: '1977-09-15'
#   >

collection
  .query
  .where(title: 'The Silmarillion', author: 'John Ronald Reuel Tolkien')
  .exists?
#=> true
```

If the collection does not include a record with the specified records's primary key, the `#update_one` command will return a failing result with a `NotFound` error.

##### Validate One

The `ValidateOne` command takes an entity and an optional `Stannum` contract. If the `:contract` keyword is given, the record is matched against the contract; otherwise, the record is matched using the native validations defined for the record class.

```ruby
book   = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
result = collection.validate_one.call(entity: book)
result.success?
#=> true
```

If the contract does not match the entity, the `#validate_one` command will return a failing result with a `ValidationFailed` error.

<a id="repositories"></a>

#### Repositories

```ruby
require 'cuprum/rails/repository'
```

A `Cuprum::Rails::Repository` is a group of Rails collections. A single repository might represent all or a subset of the tables in your database.

```ruby
repository = Cuprum::Collections::Repository.new
repository.key?('books')
#=> false

repository.add(books_collection)

repository.key?('books')
#=> true
repository.keys
#=> ['books']
repository['books']
#=> the books collection
```

<a id="controllers"></a>

### Controllers

```ruby
require 'cuprum/rails/controller'
```

> **Important Note**
>
> `Cuprum::Rails` is a pre-release gem, and there may be breaking changes between minor versions and until the API is finalized by version 1.0.0. The `Controller` API is particularly likely to experience changes as additional use cases are discovered and supported.

The Rails approach to controllers is to embrace Convention over Configuration. `Cuprum::Rails::Controller` inverts this pattern, using configuration to precisely define behavior.

```ruby
class BooksController
  include Cuprum::Rails::Controller

  def self.resource
    @resource ||= Cuprum::Rails::Resource.new(
      collection:           Cuprum::Rails::Collection.new(record_class: Book),
      permitted_attributes: %i[title author series category published_at],
      resource_class:       Book
    )
  end

  def self.serializers
    serializers       = super()
    json              = serializers.fetch(:json, {})
    record_serializer =
      Cuprum::Rails::Serializers::Json::ActiveRecordSerializer.instance

    serializers.merge(
      json: json.merge(ActiveRecord::Base => record_serializer)
    )
  end

  responder :html, Cuprum::Rails::Responders::Html::PluralResource
  responder :json, Cuprum::Rails::Responders::Json::Resource

  action :create,  Cuprum::Rails::Actions::Create
  action :destroy, Cuprum::Rails::Actions::Destroy, member: true
  action :edit,    Cuprum::Rails::Actions::Edit,    member: true
  action :new,     Cuprum::Rails::Actions::New
  action :index,   Cuprum::Rails::Actions::Index
  action :show,    Cuprum::Rails::Actions::Show,    member: true
  action :update,  Cuprum::Rails::Actions::Update,  member: true
end
```

Here, we are defining a typical Rails resourceful controller, which implements the CRUD actions for `Book`s and responds to HTML and JSON requests. As you can see, `Cuprum::Rails::Controller` is a mix of [Actions](#actions) and configuration (the [Resource](#resources), [Responders](#responders), and [Serializers](#serializers)). In a full application, some of that configuration (the responders and serializers) could be handled in an abstract base controller, such as an `APIController` that defined a JSON responder and serializers. Note also that the *implementation* of the actions happens elsewhere - the controller references existing commands to define the actions.

#### Configuring Controllers

Each controller has three main points of configuration: a `Resource`, a set of `Responders`, and a set of `Serializers`.

The [Resource](#resources) provides some metadata about the controller, such as a `#resource_name`, a set of `#routes`, and whether the controller represents a singular or a plural resource. Generally speaking, each controller should have a unique resource, which is defined by overriding the `.resource` class method.

The [Responders](#responders) determine what request formats are accepted by the controller and how the corresponding responses are generated. Responders can and should be shared between controllers, and are defined using the `.responder` class method. `.responder` takes two parameters: a `format`, which should be either a string or a symbol (e.g. `:json`) and a `responder_class`, which will be used to generate responses for the specified format.

The [Serializers](#serializers) are used in API responses (such as a JSON response) to convert application data into a serialized format. `Cuprum::Rails` defines a base set of serializers for simple data; applications can either set a generic serializer for records (as in `BooksController`, above) or set specific serializers for each record class on a per-controller basis. Serializers are defined by overriding the `.serializers` class method - make sure to call `super()` and merge the results, unless you specifically want to override the default values.

You can also define `.default_format`, which sets a default value for when the request does not specify a format. For example, a request to `/api/books.html` specifies the `:html` format, while there is no format specified for `/api/books`.

```ruby
class BooksController
  default_format :html
end
```

#### Defining Actions

A non-abstract controller should define at least one [Action](#actions), corresponding to a page, process, or API endpoint for the application. Actions are defined using the `.action` class method, which takes two parameters: an `action_name`, which should be either a string or a symbol (e.g. `:publish`), and an `action_class`, which is a subclass of `Cuprum::Rails::Action`.

```ruby
class BooksController
  action :published, Actions::Books::Published
end
```

In addition, `.action` accepts the following keywords:

- `:member`: If `true`, the action is a member action and acts on a member of the collection, rather than the collection as a whole. In a classic controller, the `:edit`, `:destroy`, `:show`, and `:update` actions are member actions.

```ruby
class BooksController
  action :publish, Actions::Books::Publish, member: true
end
```

<a id="controllers-defining-middleware"></a>

#### Defining Middleware

You can use [middleware](#middleware) to insert functionality before, after, or around controller actions. Think of it as a supercharged alternative to the traditional Rails `before_action` and `after_action` hooks, but without the magic behavior. Use cases for middleware include:

- Authentication
- Logging
- Profiling

Middleware commands have a specific interface. See [Middleware](#middleware), below, for how to define your own middleware commands.

```ruby
class BooksController
  middleware LoggingMiddleware
  middleware AuthenticationMiddleware, except: %i[index show]
  middleware ProfilingMiddleware,      only:   %i[create update]
end
```

Adding middleware to a controller is straightforward. In our example above, the `LoggingMiddleware` will run for all actions, the `AuthenticationMiddleware` will run for all actions except for `:index` and `:show`, and the `ProfilingMiddleware` will run for the `:create` and `:update` actions.

Each middleware command can have functionality that runs before, after, or around the action (and subsequent middleware). Code that runs before the action has access to the `request:`, and can modify the request passed to the next command or even skip the action and return its own result. Code that runs after the action has access to the `request:` and the action `result`, and can modify or replace the result.

The middleware is executed in the order it is defined. For the `BooksController#create` action, the code would run as follows:

1. `LoggingMiddleware`: Any code that executes before the action.
1. `AuthenticationMiddleware`: Any code that executes before the action.
1. `ProfilingMiddleware`: Any code that executes before the action.
1. `Books::CreateAction`
1. `ProfilingMiddleware`: Any code that executes after the action.
1. `AuthenticationMiddleware`: Any code that executes after the action.
1. `LoggingMiddleware`: Any code that executes after the action.

Code that runs before or around the action can skip the action and return its own result. For example, the `AuthenticationMiddleware` will check for a valid session. If there is not a valid session, it will return a failing result rather than calling the action. In this case, the code would run as follows:

1. `LoggingMiddleware`: Any code that executes before the action.
1. `AuthenticationMiddleware`: The session is not found, so the action is not called.
1. `AuthenticationMiddleware`: Any code that executes after the action.
1. `LoggingMiddleware`: Any code that executes after the action.

<a id="controllers-action-lifecycle"></a>

#### The Action Lifecycle

Inside a controller action, `Cuprum::Rails` splits up the responsibilities of responding to a request.

1. The Action
    1. The `action_class` is initialized, passing the controller `resource` to the constructor and returning the `action`.
    2. The `action` is wrapped with any `middleware` that is defined by the controller for that action.
    3. The controller `#request` is wrapped in a `Cuprum::Rails::Request`, which is passed to the `action`'s `#call` method, returning the `result`.
2. The Responder
    1. The `responder_class` is found for the request based on the request's `format` and the configured `responders`.
    2. The `responder_class` is initialized with the `action_name`, `resource`, and `serializers`, returning the `responder`.
    3. The `responder` is called with the action `result`, and finds a matching `response` based on the action name, the result's success or failure, and the result error (if any).
3. The Response
    1. The `response` is then called with the controller, which allows it to reference native Rails controller methods for rendering or redirecting.

Let's walk through this step by step. We start by making a `POST` request to `/books`, which corresponds to the `BooksController#create` endpoint with parameters `{ book: { title: 'Gideon the Ninth' } }`.

1. The Action
    1. We initialize our configured action class, which is `Cuprum::Rails::Actions::Index`.
    2. We wrap the request in a `Cuprum::Rails::Request`, and call our `action` with the wrapped `request`. The action performs the business logic (building, validating, and persisting a new `Book`) and returns an instance of `Cuprum::Result`. In our case, the book's attributes are valid, so the result has a `:status` of `:success` and a value of `{ 'book' => #<Book id: 0, title: 'Gideon the Ninth'> }`.
2. The Responder
    1. We're making an HTML request, so our controller will use the responder configured for the `:html` format. In our case, this is `Cuprum::Rails::Responders::Html::PluralResource`, which defines default behavior for responding to resourceful requests.
    2. Our `Responders::Html::PluralResource` is initialized, giving us a `responder`.
    3. The `responder` is called with our `result`. There is a match for a successful `:create` action, which returns an instance of `Cuprum::Rails::Responses::Html::RedirectResponse` with a `path` of `/books/0`.
3. The Response
    1. Finally, our `response` object is called. The `RedirectResponse` directs the controller to redirect to `/books/0`, which is the `:show` page for our newly created `Book`.

<a id="actions"></a>

### Controller Actions

```ruby
require 'cuprum/rails/action'
```

`Cuprum::Rails` extracts the business logic of controllers into dedicated `Cuprum::Rails::Action`s. Each action is a `Cuprum::Command` that is initialized with a [Resource](#resources), called with a [Request](#request), and returns a `Cuprum::Result` that is then passed to the responder.

```ruby
class PublishedBooks < Cuprum::Rails::Action
  private

  def process(request)
    super

    resource.collection.find_matching.call(order: params[:order]) do
      {
        'published_at' => not_equal(nil)
      }
    end
  end
end
```

Each action has access to the `resource` via the constructor, the `request`, and the request's `params`. Above, we are defining a simple action for returning books that have a non-`nil` publication date. Like any `Cuprum::Command`, the heart of the class is the `#process` method, which for an action takes the `request` as its sole parameter. Inside the method, we call `super` to setup the action. We then access the configured `resource`, which grants us access to the `collection` of books. Finally, we call the collection's `find_matching` command, with an optional ordering coming from the params.

The `Cuprum::Rails::Actions::ResourceAction` provides some helper methods for defining resourceful actions.

```ruby
class PublishBook < Cuprum::Rails::Actions::ResourceAction
  private

  def process(request)
    super

    step { require_resource_id }

    book = step { collection.find_one.call(primary_key: resource_id) }

    book.published_at = DateTime.current

    step { collection.validate_one.call(entity: book) }

    step { collection.update_one.call(entity: book) }
  end
end
```

`ResourceAction` delegates `#collection`, `#resource_name`, and `#singular_resource_name` to the `#resource`. In addition, it defines the following helper methods. Each method returns a `Cuprum::Result`, so you can use the `#step` control flow to handle command errors.

- `#resource_id`: Wraps `params[:id]` in a result, or returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error.
- `#resource_params`: Wraps `params[singular_resource_name]` and filters them using `resource.permitted_attributes`. Returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error if the resource params are missing, or with a `Cuprum::Rails::Errors::UndefinedPermittedAttributes` error if the resource does not define permitted attributes.

#### Transactions

`Cuprum::Rails` integrates with `ActiveRecord` to support database transactions. The `#transaction` method integrates native transactions with the `Cuprum` control flow:

```ruby
class ReturnBook < Cuprum::Rails::Actions::ResourceAction
  private

  def books_collection
    @books_collection ||= repository['books']
  end

  def process(request)
    super

    step { require_resource_id }

    loan = step { collection.find_one.call(primary_key: resource_id) }

    transaction do
      step { return_book(loan.book_id) }

      step { collection.destroy_one.call(entity: loan) }
    end
  end

  def return_book(book_id)
    step do
      books_collection.assign_one.call(
        attributes: { 'borrowed' => false },
        entity: book
      )
    end

    books_collection.update_one.call(entity: book)
  end
end
```

Here, we are defining a custom action for returning a borrowed library book. Inside our transaction, we are defining two steps. First, we are marking the book as no longer borrowed, so other patrons will be able to check it out or request it. Second, we destroy the join model between the user and the book. If either of these steps returns a failing result, the transaction will automatically roll back.

If you do not want to roll back on a failed step, use the native `ActiveRecord.transaction` method instead.

#### Actions

`Cuprum::Rails` also provides some pre-defined actions to implement classic resourceful controllers. Each resource action calls one or more commands from the resource collection to query or persist the record or records.

##### Create

The `Create` action passes the resource params to `collection.build_one`, validates the record using `collection.validate_one`, and finally inserts the new record into the collection using the `collection.insert_one` command. The action returns a Hash containing the created record.

```ruby
action     = Cuprum::Rails::Actions::Create.new(resource)
attributes = { 'book' => { 'title' => 'Gideon the Ninth' } }
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book title: 'Gideon the Ninth'> }

Book.where(title: 'Gideon the Ninth').exist?
#=> true
```

If the created record is not valid, the action returns a failing result with a `Cuprum::Collections::Errors::FailedValidation` error.

If the params do not include attributes for the resource, the action returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error.

If the permitted attributes are not defined for the resource, the action returns a failing result with a `Cuprum::Rails::Errors::UndefinedPermittedAttributes` error.

##### Destroy

The `Destroy` action removes the record from the collection via `collection.destroy_one`. The action returns a Hash containing the deleted record.

```ruby
action     = Cuprum::Rails::Actions::Destroy.new(resource)
attributes = { 'id' => 0 }
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book id: 0> }

Book.where(id: 0).exist?
#=> false
```

If the record with the given primary key does not exist, the action returns a failing result with a `Cuprum::Collections::Errors::NotFound` error.

##### Edit

The `Edit` action finds the record with the given primary key via `collection.find_one` and returns a Hash containing the found record.

```ruby
action     = Cuprum::Rails::Actions::Edit.new(resource)
attributes = { 'id' => 0 }
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book id: 0> }
```

If the record with the given primary key does not exist, the action returns a failing result with a `Cuprum::Collections::Errors::NotFound` error.

##### Index

The `Index` action performs a query on the records using `collection.find_matching`, and returns a Hash containing the found records. You can pass `:limit`, `:offset`, `:order`, and `:where` parameters to filter the results.

```ruby
action     = Cuprum::Rails::Actions::Index.new(resource)
attributes = {
  'limit' => 3,
  'order' => { 'title' => :asc },
  'where' => { 'author' => 'Ursula K. LeGuin' }
}
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'books' => [#<Book>, #<Book>, #<Book>] }
```

##### New

The `New` action builds a new record with empty attributes using `collection.build_one`, and returns a Hash containing the new record.

```ruby
action = Cuprum::Rails::Actions::New.new(resource)
result = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book> }
```

##### Show

The `Show` action finds the record with the given primary key via `collection.find_one` and returns a Hash containing the found record.

```ruby
action     = Cuprum::Rails::Actions::Show.new(resource)
attributes = { 'id' => 0 }
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book id: 0> }
```

If the record with the given primary key does not exist, the action returns a failing result with a `Cuprum::Collections::Errors::NotFound` error.

##### Update

The `Update` action finds the record with the given primary key via `collection.find_one`, assigns the given attributes using `collection.assign_one`, validates the record using `collection.validate_one`, and finally updates the record in the collection using the `collection.update_one` command. The action returns a Hash containing the created record.

```ruby
action     = Cuprum::Rails::Actions::Update.new(resource)
attributes = { 'id' => 0, 'book' => { 'title' => 'Gideon the Ninth' } }
result     = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book id: 0, title: 'Gideon the Ninth'> }

Book.find(0).title
#=> 'Gideon the Ninth'
```

If the record with the given primary key does not exist, the action returns a failing result with a `Cuprum::Collections::Errors::NotFound` error.

If the updated record is not valid, the action returns a failing result with a `Cuprum::Collections::Errors::FailedValidation` error.

If the params do not include attributes for the resource, the action returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error.

If the permitted attributes are not defined for the resource, the action returns a failing result with a `Cuprum::Rails::Errors::UndefinedPermittedAttributes` error.

<a id="middleware"></a>

### Middleware

A middleware command takes two parameters. First, a `next_command` argument, which is the next item in the middleware chain (or the controller action if the middleware is the last one in the chain). Second, a `request:` keyword - this is the [request](#requests) passed down from the controller.

See [Defining Middleware](#controllers-defining-middleware), above, for using middleware in a `Cuprum::Rails::Controller`, or see [Cuprum](github.com/sleepingkingstudios/cuprum) for more information on middleware.

#### Before An Action

Middleware commands can run before an action, similar to a native Rails `before_action` filter.

```ruby
class AuthenticationMiddleware < Cuprum::Command
  include Cuprum::Middleware

  private def process(next_command, request:)
    step { Authentication::RequireUser.call(request: request) }

    super
  end
end
```

Here, we are creating a basic middleware command. We call our authentication command in a `step`, meaning that if the authentication command returns a failing result, we will immediately return that result. This means that our action will not run if the session is invalid.

If the authentication command returns a passing result, we call `super` to invoke the default behavior of `Cuprum::Middleware`. This calls `next_command.call(request: request)` to continue the middleware or invoke the action.

#### After An Action

Likewise, middleware commands can run after an action, similar to a native Rails `after_action` filter.

```ruby
class LoggingMiddleware < Cuprum::Command
  include Cuprum::Middleware

  private def process(next_command, request:)
    result = next_command.call(request: request)

    if result.success?
      Rails.logger.info(
        "Successful Request: controller: #{request.controller_name}, action:" \
          " #{request.action_name}"
      )
    else
      Rails.logger.error(
        "Failed Request: controller: #{request.controller_name}, action:" \
          " #{request.action_name}, error: #{result.error.as_json}"
      )
    end

    result
  end
end
```

This middleware is a little more complicated. Instead of intercepting the request before the action, here we are taking the result of the action and implementing some custom behavior based on the success or failure of the action. Finally, make sure to return the result.

Note that we are explicitly calling `next_command.call(request: request)` rather than relying on `super`. This is because `super` calls the next command inside a `step`, and will immediately return a failing result rather than continuing through `#process`. For our logging middleware, however, we actually want to handle both passing and failing results.

#### Around An Action

Finally, we can run middleware around an action, similiar to a native Rails `around_action` filter.

```ruby
class ProfilingMiddleware < Cuprum::Command
  include Cuprum::Middleware

  private

  def process(next_command, request:)
    start_time = Time.current

    value = super(next_command, request: request)

    return if value.nil?

    end_time = Time.current

    value.merge('time_elapsed' => time_elapsed(start_time, end_time))
  end

  def time_elapsed(start_time, end_time)
    difference = ((end_time - start_time).round(3) * 1_000).to_i

    "#{difference} milliseconds"
  end
end
```

We start by capturing the current time, before the action is run. We then call the action via `super`; this means that the middleware will return immediately on a failed result. Once the action has run, we calculate how long the action took to run and merge that into the result value. In a production environment, we would probably pass that data to a monitoring service.

<a id="requests"></a>

### Requests

```ruby
require 'cuprum/rails/request'
```

A `Cuprum::Rails::Request` is a value object that encapsulates the details of a controller request, such as the request `format`, the `headers`, and the `parameters`. Generally speaking, users should not instantiate requests directly; they are used as part of the [Controller action lifecycle](#controllers-action-lifecycle).

Each request defines the following properties:

- `#authorization`: The value of the `"AUTHORIZATION"` header, if any, as a `String`.
- `#body_parameters`: (also `#body_params`) The parameters derived from the request body, such as a JSON payload or form data. A `Hash` with `String` keys.
- `#format`: The format of the request as a `Symbol`, e.g. `:html` or `:json`.
- `#headers`: The request headers, as a `Hash` with `String` keys.
- `#method`: The HTTP method used for the request as a `Symbol`, e.g. `:get` or `:post`.
- `#parameters`: (also `#params`) The complete parameters for the request, including both params from the request body and from the query string. A `Hash` with `String` keys.
- `#path`: The relative path of the request, including query params.
- `#path_parameters`: (also `#path_params`) The path parameters for the request, minus the Rails-provided `action` and `controller` params. A `Hash` with `String` keys.
- `#query_parameters`: (also `#query_params`) The query parameters for the request. A `Hash` with `String` keys.

The request properties can also be accessed via the `#[]` method (using either String or Symbol keys), or updated via the `#[]=` method. The `#properties` method returns all of the request properties as a `Hash`.

<a id="resources"></a>

### Resources

```ruby
require 'cuprum/rails/resource'
```

A `Cuprum::Rails::Resource` defines the configuration for a resourceful controller.

```ruby
resource = Cuprum::Rails::Resource.new(
  collection:     Cuprum::Rails::Collection.new(record_class: Book),
  resource_class: Book
)
resource.resource_name
#=> 'books'
```

A resource must be initialized with either a `resource_class` or a `resource_name`. It defines the following properties:

- `#base_url`: The base url for the collection, used when generating routes.
- `#collection`: A `Cuprum::Collections` collection, used to perform queries and persistence operations on the resource data. If not given and the collection has a `#resource_class`, then a `Cuprum::Rails::Collection` is automatically generated.
- `#resource_class`: The `Class` of items in the resource.
- `#resource_name`: The name of the resource as a `String`. If the resource is initialized with a `resource_class`, the `resource_name` is derived from the given class.
- `#routes`: A [Cuprum::Rails::Routes](#routes) object for the resource. If not given, a default routes object is generated for the resource.
- `#singular`: If true, the resource is a singular resource (e.g. `/user`, as opposed to the plural `/books` resource). Also defines the `#singular?` and `#plural` predicates.

<a id="routes"></a>

#### Routes

Each resource has a `Cuprum::Rails::Routes` object that represents the routes implemented for the controller. The routes are typically used in responders when generating the controller response (see [Responders](#responders), below).

```ruby
routes = Cuprum::Rails::Routes.new(base_path: '/books') do
  route :published, 'published'
  route :publish,   ':id/publish'
end
routes.published_path
#=> '/books/published'
```

Some routes include **wildcards**, such as the `:publish` route above which requires an `:id` wildcard; nested resources will require a wildcard value (the parent resource id) for all resourceful routes. Wildcards are assigned using the `#with_wildcards` method, which creates a copy of the routes object with the assigned wildcards.

```ruby
routes.publish_path
#=> raises a Cuprum::Rails::Routes::MissingWildcardError exception
routes.with_wildcards(id: 0).publish_path
#=> /books/0/publish
```

`Cuprum::Rails` defines templates for defining resourceful routes for both singular and plural resources.  These define the standard CRUD operations for a resource.

```ruby
routes = Cuprum::Rails::Routing::PluralRoutes.new(base_path: '/books')
routes = routes.with_wildcards(id: 0)
routes.create_path
#=> '/books'
routes.destroy_path
#=> '/books'
routes.edit_path
#=> '/books/0/edit'
routes.index_path
#=> '/books'
routes.new_path
#=> '/books/new'
routes.show_path
#=> '/books/0'
routes.update_path
#=> '/books/0'

routes = Cuprum::Rails::Routing::SingularRoutes.new(base_path: '/book')
routes.create_path
#=> '/book'
routes.destroy_path
#=> '/book'
routes.edit_path
#=> '/book/edit'
routes.new_path
#=> '/book/new'
routes.show_path
#=> '/book'
routes.update_path
#=> '/book'
```

<a id="responders"></a>

### Responders

In a `Cuprum::Rails` controller, the responder is responsible for turning the action result into a response (see [The Action Lifecycle](#controllers-action-lifecycle), above). Each request format should have a dedicated responder, e.g. an `HtmlResponder` is used to respond to HTML requests.

```ruby
class CustomResponder < Cuprum::Rails::Responders::HtmlResponder
  action :publish do
    match :success do
      redirect_to(resource.routes.show_path)
    end

    match :failure do
      render 'show'
    end
  end

  match :failure, error: Authorization::NotAuthorizedError do
    redirect_to(login_path)
  end

  private

  def login_path
    '/login'
  end
end
```

First, we are using the `.action` class method to define responses for the `:publish` action. If the result is successful, it redirects to the `:show` page. If the result is failing, it instead renders the `:show` page and assigns the error (if any) to `@error`. Next, we are using the `.match` class method to define a response for a failing result with an `Authorization::NotAuthorizedError`.

A result will be matched to a response in order of specificity:

- An `.action` clause with a matching `error:` (if any).
- A generic `.match` clause with a matching `error:`.
- An `.action` clause with a matching status, either `:success` or `:failure`.
- A generic `.match` clause with a matching status.

In our case, consider a `:publish` request that fails with an `Authorization::NotAuthorizedError`. The responder will first check for a clause matching both the action and the error. It will then check for a generic action response with the error, which the `.match` clause we defined. If the request failed with a different error, the responder would not find a match for the error, and would fall back to the generic `:failure` clause for the action. Finally, if there was no `.action` clause for the action, or the clause did not specify a `:failure` clause, it would perform the generic `:failure` clause for any action.

`Cuprum::Rails` also defines the following built-in responders:

**Cuprum::Rails::Responders::HtmlResponder**

Provides default responses for HTML requests.

- For a successful result, renders the template for the action and assigns the result value as local variables.
- For a failing result, redirects to the resource `:index` page (for a collection action) or the resource `:show` page (for a member action).

**Cuprum::Rails::Responders::Html::PluralResource**

Provides some additional response handling for plural resources.

- For a failed `#create` result, renders the `:new` template.
- For a successful `#create` result, redirects to the `:show` page.
- For a successful `#destroy` result, redirects to the `:show` page.
- For a failed `#index` result, redirects to the root page.
- For a failed `#update` result, renders the `:edit` template.
- For a successful `#update` result, redirects to the `:show` page.

**Cuprum::Rails::Responders::Html::SingularResource**

Provides some additional response handling for singular resources.

- For a failed `#create` result, renders the `:new` template.
- For a successful `#create` result, redirects to the `:show` page.
- For a successful `#destroy` result, redirects to the parent resource.
- For a failed `#update` result, renders the `:edit` template.
- For a successful `#update` result, redirects to the `:show` page.

**Cuprum::Rails::Responders::JsonResponder**

Provides default responses for JSON requests.

- For a successful result, serializes the result value and generates a JSON object of the form `{ ok: true, data: serialized_value }`.
- For a failing result, creates and serializes a generic error and generates a JSON object of the form `{ ok: false, error: serialized_error }` and a status of `500 Internal Server Error`. If the Rails environment is `:development`, it will instead serialize the error from the result.

**Cuprum::Rails::Responders::Json::Resource**

- For a successful `#create` result, serializes the result value with a status of `201 Created`.
- For a failed result with an `AlreadyExists` error, serializes the error with a status of `422 Unprocessable Entity`.
- For a failed result with a `FailedValidation` error, serializes the error with a status of `422 Unprocessable Entity`.
- For a failed result with a `MissingParameters` error, serializes the error with a status of `400 Bad Request`.
- For a failed result with a `NotFound` error, serializes the error with a status of `404 Not Found`.

<a id="responses"></a>

#### Responses

Response objects implement the final step of [the Action Lifecycle](#controllers-action-lifecycle), and are returned when a [Responder](#responders) is `#call`ed. Each response class implements a specific type of response, such as an HTML redirect or a serialized JSON response, and encapsulates the data necessary to perform that response.

Internally, each response delegates to the `renderer`, which must be passed to the `#call` method. This delegation allows the response to abstract out the details of generating a response to the renderer. During the action lifecycle, the renderer will be the controller instance.

```ruby
data     = {
  'ok'   => 'true',
  'data' => { 'book' => { 'title' => 'Gideon the Ninth' } }
}
response = Cuprum::Rails::Responses::JsonResponse.new(data: data)
renderer = instance_double(ActionController::Base, render: nil)

response.call(renderer)
expect(renderer).to have_received(:render).with(json: data)
#=> true
```

Responses should not be generated directly; they are created as part of the action lifecycle.

`Cuprum::Rails` defines the following responses:

**Cuprum::Rails::Responses::Html::RedirectResponse**

A response for an HTML redirect. Takes the redirect `path` and an optional `:status` keyword, and calls `renderer.redirect_to`.

**Cuprum::Rails::Responses::Html::RenderResponse**

A response for an HTML rendered view. Takes the `template` to render, as well as optional keywords for the `:layout`, the `:status`, and the `:assigns` to assign as local variables. Calls `renderer.render`.

**Cuprum::Rails::Responses::JsonResponse**

A response for a JSON request. Takes the serialized `:data` to return as well as an optional `:status` keyword. Calls `renderer.render` with the `json:` option.

<a id="serializers"></a>

### Serializers

Serializers convert entities and data structures into serialized data. Each serializer is specific to one format and one type of object - for example, the `Cuprum::Rails::Serializers::Json::ErrorSerializer` generates a JSON representation of a `Cuprum::Error`.

Serialization is context-specific - one controller may use one serializer for a particular record class, while another controller may use a limited set of attributes, such as an admin versus a user-facing controller. To handle this, the `#call` method must accept a `:context` keyword, which is an instance of `Cuprum::Rails::Serializers::Context`. Each context is initialized with a set of serializers that are used to serialize attributes, array items or hash values, associated models, or otherwise nested properties. All of this is handled automatically inside the controller action.

```ruby
class StructSerializer < Cuprum::Rails::Serializers::JsonSerializer
  def call(struct, context:)
    struct.each_pair.with_object do |(key, value), hsh|
      hsh[key] = super(value, context: context)
    end
  end
end

serializer = StructSerializer.new
context    = Cuprum::Rails::Serializers::Context.new(
  serializers: Cuprum::Rails::Serializers::Json.default_serializers
)
struct     =
  Struct
  .new(:series, :author, :titles)
  .new('The Locked Tomb', 'Tamsyn Muir', ['Gideon the Ninth', 'Harrow the Ninth'])
serializer.call(struct, context: context)
#=> {
#     'series' => 'The Locked Tomb',
#     'author' => 'Tamsyn Muir',
#     'titles' => ['Gideon the Ninth', 'Harrow the Ninth']
#   }
```

Above, we define a custom serializer for serializing `Struct` instances. We then use the serializer on our Book-like struct by passing it to the `#call` method, along with a serialization context that contains the default JSON serializers. The `#call` method takes each pair of keys and values and calls `super()`, which finds the configured serializer for each value. In our case, the default serializer for a `String` returns the string, while the default serializer for an `Array` returns a new array whose items are the serialized array items. Finally, a `Hash` with `String` keys is generated, which is our `Struct` serialized into a JSON-compatible object.

`Cuprum::Rails` defines the following serializers:

**Cuprum::Rails::Serializers::Json::Serializer**

The base class for JSON serializers. Takes a configured `context:` and finds the serializer for the given object, then calls that serializer with the object and the given context.

The serializer for an object is determined based on the object's class. Specifically, for each ancestor of the object's class, the configured serializers are checked for a key matching that ancestor. If that class or module is a key in the configured hash, then the corresponding serializer is used to serialize the object. If the configured serializers do not include a serializer for any of the object class's ancestors, raises an `UndefinedSerializerError`.

**Cuprum::Rails::Serializers::Json::AttributesSerializer**

Serializes an object by finding and calling the configured serializer (see above) for each attribute defined for the serializer. See [Attribute Serializers](#attribute-serializers) below.

**Cuprum::Rails::Serializers::Json::ActiveRecordSerializer**

Serializes an `ActiveRecord` model by delegating to the `#as_json` method. An alternative to defining a specific `AttributeSerializer` (see above) for each model class.

**Cuprum::Rails::Serializers::Json::ArraySerializer**

Serializes an `Array` by finding and calling the configured serializer for each array item (see above). This is the default serializer for `Array`s.

**Cuprum::Rails::Serializers::Json::ErrorSerializer**

Serializes a `Cuprum::Error` by delegating to the `#as_json` method. This is the default serializer for errors.

**Cuprum::Rails::Serializers::Json::HashSerializer**

Serializes a `Hash` with `String` keys by finding and calling the configured serializer for each hash value (see above). This is the default serializer for `Hash`es.

**Cuprum::Rails::Serializers::Json::IdentitySerializer**

Serializes a value object by returning the object. This is the default serializer for `nil`, `true`, `false`, `Integer`s, `Float`s, and `String`s.

<a id="attribute-serializers"></a>

#### Attribute Serializers

Attribute serializers define a set of attributes to be serialized. This is useful for whitelisting a specific set of attributes to return in the serialized object.

```ruby
class RecordSerializer < Cuprum::Rails::Serializers::Json::AttributesSerializer
  attribute :id
end

class BookSerializer < RecordSerializer
  attribute :title
  attribute :author
  attribute :series
end

class DetailedBookSerializer < BookSerializer
  attribute :category
  attribute :published_at
end


context    = Cuprum::Rails::Serializers::Context.new(
  serializers: Cuprum::Rails::Serializers::Json.default_serializers
)
book       = Book.new(
  id:       0,
  title:    'Nona The Ninth',
  author:   'Tamsyn Muir',
  series:   'The Locked Tomb',
  category: 'Science Fiction and Fantasy',
)

BookSerializer.new.call(book, context: context)
#=> {
#     'id'     => 0,
#     'title'  => 'Nona The Ninth',
#     'author' => 'Tamsyn Muir',
#     'series' => 'The Locked Tombs'
#   }

DetailedBookSerializer.new.call(book, context: context)
#=> {
#     'id'           => 0,
#     'title'        => 'Nona The Ninth',
#     'author'       => 'Tamsyn Muir',
#     'series'       => 'The Locked Tombs',
#     'category'     => 'Science Fiction and Fantasy',
#     'published_at' => nil
#   }
```

Above, we define an abstract `RecordSerializer` and a `BookSerializer`, which inherits the `:id` attribute and defines the `:title`, `:author`, and `:series` attributes. When the book serializer is called, it serializes the values of each attribute using the configured serializers; any attributes that are not defined on the serializer are ignored.

We also define a `DetailedBookSerializer` which inherits from `BookSerializer`. This allows us to reuse the attributes defined for our basic book serializer.
