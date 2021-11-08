# Cuprum::Rails

An integration between Rails and the Cuprum library.

Cuprum::Rails defines the following objects:

- [Collections](#collections): A collection for performing operations on ActiveRecord models using the standard `Cuprum::Collections` interface.
    - [Commands](#commands): Each collection is comprised of `Cuprum` commands, which implement common collection operations such as inserting or querying data.
- [Controllers](#controllers): Decouples controller responsibilities for precise control, reusability, and reduction of boilerplate code.
    - [Actions](#actions): Implement a controller's actions as a `Cuprum` command.
    - [Requests](#requests): Encapsulates a controller request.
    - [Resources](#resources): @todo
    - [Responders](#responders) and [Responses](#responses): @todo
    - [Serializers](#serializers): @todo

## About

Cuprum::Rails provides a toolkit for using the Cuprum command pattern and the flexibility of Cuprum::Collections to build Rails applications. Using the `Cuprum::Rails::Collection`, you can perform operations on ActiveRecord models, leveraging a standard interface to control where your data is stored and how it is queried. For example, you can inject a mock collection into unit tests for precise control over queried values and blinding fast tests without having to hit the database directly.

Using `Cuprum::Rails::Controller` takes this one step further, breaking apart the traditional controller into a sequence of steps with individual responsibilities. This has two main benefits. First, being explicit about how your controllers perform and respond to actions allows for precise control at each step of the process. Second, each step is encapsulated, which allows for easier testing and reuse. This not only makes testing simpler - you can test your business logic by examining an Action result, rather than parsing a rendered HTML page - but allows you to reuse individual components. The goal is to reduce the boilerplate inherent in writing a Rails application by allowing you to define only the code that is unique to the controller, action, or process.

### Why Cuprum::Rails?

Rails is a highly opinionated framework: one of the pillars of The Rails Doctrine is the principle that "The menu is omakase". This is one of the keys to the framework's success, providing a welcoming environment for new developers as well as powerful tools for developing applications - as long as those applications are built The Rails Way.

This is great for rapidly developing prototypes, proof of concept or proof of market applications, or even smaller applications for content management, e-commerce, and so on. There are good reasons why Rails has made so much headway against established behemoths such as WordPress. That being said, many companies are using Rails to build applications that are much more ambitious, and at that scale the standard Rails patterns start to fall apart. Omakase is no longer just right.

Cuprum::Rails is intended to address two of the pain points of Big Rails. The first is architectural: any Rails developer of a certain age will remember the wars over Fat Controllers versus Fat Models. The rise of Service Objects provides a way forward, but in practice this can be something of a Wild West - everything gets dumped in an `app/services` directory, each file looks and works differently. The [Cuprum](github.com/sleepingkingstudios/cuprum) gem is designed to provide a solution to this chaos. Defining a command gives you the benefits of encapsulation, control flow, and *consistency* - every command defines one `#call` method and returns a result.

The second benefit is *reusability*. Breaking down a controller into its constituent steps means you don't have to reimplement each of those steps each time you create a controller or add an action. You can define what it means to respond to an HTML or JSON request once, and modify it on a per-action basis when you need custom behavior. You can subclass the resourceful action commands to leverage basic controller functionality, such as performing filtered queries. And, of course, you gain all the benefits of decoupling commands from your controller - you can use the same functionality in a controller action, as an asynchronous job, or as a command-line function.

### Compatibility

Cuprum::Collections is tested against Ruby (MRI) 2.6 through 3.0.

### Documentation

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2021 Rob Smith

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

<a id="controllers-action-lifecycle"></a>

#### The Action Lifecycle

Inside a controller action, `Cuprum::Rails` splits up the responsibilities of responding to a request.

1. The Action
    1. The `action_class` is initialized, passing the controller `resource` to the constructor and returning the `action`.
    2. The controller `#request` is wrapped in a `Cuprum::Rails::Request`, which is passed to the `action`'s `#call` method, returning the `result`.
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

### Actions

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
    book_id = step { resource_id }
    book    = step { collection.find_one.call(entity_id: book_id) }

    book.published_at = DateTime.current

    step { collection.validate_one.call(entity: book) }

    step { collection.update_one.call(entity: book) }
  end
end
```

`ResourceAction` delegates `#collection`, `#resource_name`, and `#singular_resource_name` to the `#resource`. In addition, it defines the following helper methods. Each method returns a `Cuprum::Result`, so you can use the `#step` control flow to handle command errors.

- `#resource_id`: Wraps `params[:id]` in a result, or returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error.
- `#resource_params`: Wraps `params[singular_resource_name]` and filters them using `resource.permitted_attributes`. Returns a failing result with a `Cuprum::Rails::Errors::MissingParameters` error if the resource params are missing, or with a `Cuprum::Rails::Errors::UndefinedPermittedAttributes` error if the resource does not define permitted attributes.

`Cuprum::Rails` also provides some pre-defined actions to implement classic resourceful controllers. Each resource action calls one or more commands from the resource collection to query or persist the record or records.

#### Create

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

#### Destroy

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

#### Edit

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

#### Index

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

#### New

The `New` action builds a new record with empty attributes using `collection.build_one`, and returns a Hash containing the new record.

```ruby
action = Cuprum::Rails::Actions::New.new(resource)
result = action.call(request)
result.success?
#=> true
result.value
#=> { 'book' => #<Book> }
```

#### Show

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

#### Update

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
- `#query_parameters`: (also `#query_params`) The query parameters for the request. A `Hash` with `String` keys.

<a id="resources"></a>

### Resources

@todo

#### Routes

@todo

<a id="responders"></a>

### Responders

@todo

<a id="responses"></a>

#### Responses

@todo

<a id="serializers"></a>

### Serializers

@todo
