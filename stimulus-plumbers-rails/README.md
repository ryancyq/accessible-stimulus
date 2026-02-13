# Stimulus Plumbers

A library of semantically correct, accessible UI components for Rails 8.0+ using ViewComponent and Stimulus.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stimulus_plumbers'
```

And then execute:

```bash
bundle install
```

## Usage

Stimulus Plumbers provides ready-to-use ViewComponent components that render semantically correct, accessible HTML. Each component is designed with accessibility as a core requirement, not an afterthought.

### Basic Example

```erb
<%# In your Rails view %>
<%= render ButtonComponent.new(url: root_path) do %>
  Click me
<% end %>
```

### Available Components

- **ActionList**: Accessible lists with items and sections
- **Avatar**: User avatar component
- **Button**: Semantic button with optional prefix/suffix
- **Card**: Card component with sections
- **Calendar**: Date calendar with navigation
- **Container**: Layout container
- **Divider**: Semantic divider/separator
- **Dropdown**: Accessible dropdown menus
- **Navigation**: Navigation bars, tabs, and lists
- **Popover**: Accessible popover component

## Component Philosophy

All components in this library follow these principles:

1. **Accessibility First**: WCAG 2.1 Level AA minimum
2. **Semantic HTML**: Use native elements before ARIA
3. **Keyboard Navigation**: Full keyboard support
4. **Screen Reader Friendly**: Proper announcements and labels
5. **Focus Management**: Visible focus indicators and logical tab order

## Development

After checking out the repo, run:

```bash
bundle install
```

Run the test suite with:

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryancyq/stimulus-plumbers.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
