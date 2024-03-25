# sidekiq_search

This gem provides a uniform way to programmatically access Sidekiq jobs.

Often, there is a need to retrieve a job from Sidekiq and do something with it. For example, in a Rails app to reschedule an already scheduled job. Sidekiq has an [API][1] for these things, but it's not that easy to use for the following reasons:
- enqueued, scheduled/retried/dead and running job sets (and job objects) have slightly different interfaces
- the API can change from version to version
- the API details are a bit hard to recall for most of us mere mortals

`sidekiq_search` is an answer to these problems.

### A word of caution
How and what this gem does may, in certain circumstances, be suboptimal, but it _seems like_ there is no better way to do this in the OSS version of Sidekiq. Later in this document I will explain the shortcomings of the approach that is taken, but please be warned that if your application has a lot of jobs you might run into memory or/and performance issues.

## Usage
```ruby
# The gem has a single method, `.jobs`. It simply returns an array of hashes
# where each hash contains job parameters.
jobs = SidekiqSearch.jobs(
  # Specify the categories where you want to look up the jobs.
  # For the full list, see `SidekiqSearch::JOB_CATEGORIES`
  from_categories: ['scheduled', 'dead']

  # Specify the queues where you want to look up the jobs.
  from_queues: ['default', 'your_custom_queue'],
)
#=>
# [
#   {
#     job_object: #<Sidekiq::SortedEntry:…>,
#     class: "YourCustomJob",
#     arguments: ['foo', 3],
#     …
#   },
#   …
# ]
# For the full list see the `serialize_*` methods in the source code.

# Use what you like to filter, map, etc. the collection:
that_job = jobs.find do |job|
  job[:class] == 'YourCustomJob' && job.dig(:arguments, 1) == 3
end

that_job[:job_object]
#=> #<Sidekiq::…>
# Will return either a Sidekiq::JobRecord (if the job is from enqueued
# category) or Sidekiq::SortedEntry (if the job is from scheduled,
# retried or dead categories), or Sidekiq::JobRecord (if the job is from
# running category).
# For the jobs from running category, the job hash will contain extra
# fields; please refer to the source code for more details.
```

## Shortcomings
There are two ways to retrieve jobs from Sidekiq, either to call `#to_a` on a category set (like `Sidekiq::ScheduledSet`, for example), or to use the [scan][5] method. The latter is much more efficient, both in terms of memory and performance, but unfortunately it is only available for the scheduled, retried and dead categories. If one needs to find out what jobs are currently executing or are in the enqueued state, getting an array of all the jobs in the category is the only way.
Another difficulty with `scan` is that it is quite low-level (down to Redis and job JSON payload) and implementation-dependent. So using the "to_a-way" was the natural, and only, choice.

The problem with it, however, is that we first need to have a copy of all the job data (even that that will eventually be filtered out) in memory, and only after we have it, we can start searching/filtering/mapping/etc. This is why the gem uses the opt-in approach and requires you to explicitly specify the queues and categories where you want the job to be searched: this helps to reduce the memory usage by not getting into memory the jobs unnecessarily.

Still, on a system with thousands of jobs, this might be a source of memory and performance issues, so make sure you understand all the risks.

## Development
To develop and experiment you will most likely need some jobs. Development scripts expect them to be in the `jobs` folder, in the gem's root folder. It's added to `.gitignore` so that everyone could have their jobs as they like.

`bin/console` gives you a dev console with a `_flush_all` method to quickly wipe all existing jobs.

`bin/sidekiq` launches Sidekiq locally. It expects Sidekiq configuration to be present in `bin/sidekiq_config.yml`.

`bin/ui` starts Sidekiq's UI at `http://localhost:3000`.

## Useful links
- [Sidekiq API][1]
- [Sidekiq API code][2]
- [Sidekiq API docs][3]
- [Development session log][4]

[1]: https://github.com/sidekiq/sidekiq/wiki/API "Sidekiq API"
[2]: https://github.com/sidekiq/sidekiq/blob/main/lib/sidekiq/api.rb "Sidekiq API code"
[3]: https://rubydoc.info/github/sidekiq/sidekiq/Sidekiq/Queue "Sidekiq API docs"
[4]: https://gist.github.com/kinkou/f1e5f48a6e92493192c114f2ffb2435b "Development session log"
[5]: https://github.com/sidekiq/sidekiq/wiki/API#scan "scan"