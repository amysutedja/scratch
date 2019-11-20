# Scratch

The mixtape modification command line tool.

## Prerequisites

You should have Ruby 2.6.3 installed. (If you need to install it, you can't go wrong with rbenv: https://github.com/rbenv/rbenv)

## Getting Started

Execute:

    $ bundle

## Installation

If you'd like, you can install this gem into your system gems:

    $ rake install

This gives you the ability to run `scratch`.

You have the option of not installing this gem, in which case you should run in this directory and replace instances of `scratch` below with `bundle exec exe/scratch`.

## Usage

The `scratch` function takes three paths.

    $ scratch <input> <changes> <output>

The _input_ path should be the path to a mixtape data file in the predefined format.

The _changes_ path should be the path to a changes file in JSON Lines format.

The _output_ path should be the path to which you want your new mixtape file written.

## Assumptions

- _Objects in the mixtape data should have unique ids._ This is pretty much implied but I'm calling it out here to make it maintext rather than subtext.
- _Validation is important._ I didn't see this in the specification, but I put some in anyway.
- _It's not possible for a changes file to add to or delete from a playlist that the changes file is creating._ Again, implied.

## The Changes File

The changes file describes changes to be applied to the mixtape data file. These changes are expressed in JSON Lines format. (You can read more about JSON Lines here: http://jsonlines.org/)

Structurally, a changes file comprises multiple newline-delimited JSON documents which each describe a single change. Each change document includes the following information:

- _action_: An enum value describing the type of change to perform.

In addition, it may contain one or more of the following as required to apply the change: _user_id_, _song_id_, or _playlist_id_.

Example changes file:

```
{ "action": "add_playlist", "user_id": "1", "song_id": "8" }
{ "action": "add_song", "playlist_id": "4", "song_id": "32" }
{ "action": "remove_playlist", "playlist_id": "1" }
```

## Scaling Up

Let's think about the following angles for scale issues in the application: A large changes file and/or a large input file. We'll take the scenarios one-by-one.

### Small Input File and Large Changes File

Assume that changes are small (e.g., we don't need to batch-add a million songs at once to a playlist) and that the output file ultimately can fit into memory.

This scenario should already be handled via the use of the JSON Lines format. We can read from the file and stop at each linebreak, parse the data into a JSON in-memory structure, and then apply the change.

### Large Input File and Small Changes File

Large input files are a trickier problem with DOM JSON parsers, which want a completely valid JSON document. In this situation, we might be able to use a streaming JSON parser/writer for navigating the JSON. Using this, we can do the following:

- Read the changes file into a batch
- Read the input file with a streaming reader
- For each token, apply any changes as necessary from the batch, then write the output with a streaming writer

We put the changes into a batch so that we can do a write in a single pass.

Here are some additional catches.

- Each object expressed in the input file has an id which is implied to be unique. As we read, we need to track the maximum sequence ids so that insertions can generate a correctly unique id.
- Validation of changes starts becoming an issue, assuming we want it. If we do, we have to navigate the whole file in order to gather a list of valid ids for validation.

### Large Input File and Large Changes File

Assume that we have enough space to create a temp file that will be as large as what the output will end up being.

We can build on our work in the _Large Input File and Small Changes File_ scenario and do the following.

- Read a subset of changes into a batch
- Read the input file with a streaming reader
- For each token, apply any changes as necessary from the batch, then write to a temp file with a streaming writer
- Repeat, treating the temp file as input file, until all changes are exhausted, then write the final output file

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scratch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Scratch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/scratch/blob/master/CODE_OF_CONDUCT.md).
