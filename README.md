# nanojoshu

![Hakase presents a Snickers candy bar to her sister, Nano](snickers.jpg)

[**@nanojoshu**][nanojoshu] (なの助手, *Assistant Nano*) is the name of my Twitter bot. This repository contains the code that runs it. Right now it has the following features:

* Sends a direct message whenever someone unfollows me on Twitter

[nanojoshu]: https://twitter.com/nanojoshu


## Installation

1. Install [Ruby] and [Bundler]. The code has been tested on Ruby 2.3 and 2.4—other versions may work, but are not supported.

2. Run `bundle` to install dependencies.

3. Create a `.env` file with the following contents:

    ```sh
    TARGET_USER="..."
    TWITTER_CONSUMER_KEY="..."
    TWITTER_CONSUMER_SECRET="..."
    TWITTER_ACCESS_TOKEN="..."
    TWITTER_ACCESS_TOKEN_SECRET="..."
    ```

    Put your screen name in `TARGET_USER` (your personal handle, not the bot's).

    Fill out the remaining four fields with values from [apps.twitter.com]. Make sure you set permissions to "Read, Write and Access direct messages" before generating the tokens.

3. Start the bot with `./run.sh`.

[Ruby]: https://www.ruby-lang.org
[Bundler]: https://bundler.io
[apps.twitter.com]: https://apps.twitter.com
