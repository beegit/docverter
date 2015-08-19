# Docverter Server

Docverter is a document conversion server with an HTTP interface.
It wraps the following open-source software in a JRuby app:

* [Pandoc](http://johnmacfarlane.net/pandoc/) for plain text to HTML and ePub conversion
* [Flying Saucer](http://code.google.com/p/flying-saucer/) for HTML to PDF
* [Calibre](http://calibre-ebook.com/) for ePub to MOBI conversion

## Installation

Installing on Heroku is the easiest option. Simply clone the repo, create an app, and push:

    $ git clone https://github.com/beegit/docverter.git
    $ cd docverter
    $ heroku create --buildpack https://github.com/ddollar/heroku-buildpack-multi.git
    $ heroku config:add PATH=bin:/app/bin:/app/jruby/bin:/usr/bin:/bin:/app/calibre/bin
    $ heroku config:add LD_LIBRARY_PATH=/app/calibre/lib
    $ git push heroku master

If you'd like to install locally, first ensure that Jruby, Pandoc and Calibre are installed and available. Then (for Ubuntu):

    $ jruby -S gem install foreman
    $ git clone https://github.com/beegit/docverter.git
    $ cd docverter
    $ sudo foreman export upstart /etc/init -u <some app user> -a docverter -l /var/log/docverter
    $ sudo service docverter start

Other distributions will be similar. See the documentation for [Foreman](http://ddollar.github.com/foreman/) for
more export options.

For a development server, try:

    $ rvm install jruby-1.7.4
    $ bundle install
    $ gem install foreman
    $ foreman start

## Usage

###### Ruby

See `doc/api.md` and [Docverter Ruby](https://github.com/beegit/docverter-ruby) for usage documentation.

###### PHP

See `doc/examples/php/markdown_to_pdf.php` for usage documentation.

###### Python
See https://github.com/msabramo/pydocverter

## Pandoc Build Instructions For Heroku

Docverter requires `pandoc` and needs it in a gzip'd executable in a publicly
available file (linked to in `.vendor_urls`). To make one of these, you will
first need to follow the instructions [here](https://haskellonheroku.com/tutorial/#use-a-one-off-dyno)
, run `heroku run bash` to get a CLI into your new build machine, then run:

    restore

    cabal update

    cabal install hsb2hs
    cabal install --flags="embed_data_files" pandoc pandoc-citeproc

    cd sandbox
    tar -cvxf ../pandoc.tar.gz ./bin/pandoc
    cd ../

    file=pandoc.tar.gz
    bucket=$HALCYON_S3_BUCKET
    resource="/${bucket}/${file}"
    contentType="application/x-compressed-tar"
    dateValue=`date -R`
    stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
    s3Key=$HALCYON_AWS_ACCESS_KEY_ID
    s3Secret=$HALCYON_AWS_SECRET_ACCESS_KEY
    signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
    curl -L -X PUT -T "${file}" \
    -H "Host: ${bucket}.s3.amazonaws.com" \
    -H "Date: ${dateValue}" \
    -H "Content-Type: ${contentType}" \
    -H "Authorization: AWS ${s3Key}:${signature}" \
    https://${bucket}.s3.amazonaws.com/${file}

It's is probably good to note here that on a free tier heroku instance, this
will take at least 2 hours.

This will create an executable that the heroku buildpack will unzip on compile.
Make sure to setup your S3 bucket so that your `tar.gz` file is publicly available.
