#!/bin/sh
#
# If you choose to create a runtime generated /about.html page, inside the `httpd` container
# then run this script after your `docker-compose up -d` command has completed.
#
SERVICE_LIST=`docker ps --all --format "<tr><td>{{.Names}}</td><td>{{.Image}}</td><td>{{.RunningFor}}</td></tr>" | sort `

cat <<EOP > /tmp/about.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Reference implementation of a research application suite built for PIC-SURE programs. Based on a microservices architecture with docker containers.">
    <meta name="author" content="avillach_lab_developers@googlegroups.com">

    <title>PIC-SURE Reference Implementation · AvlLab</title>

    <link rel="canonical" href="https://github.com/hms-dbmi/pic-sure-i2b2-transmart">

    <!-- Bootstrap core CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

    <style>
      .bd-placeholder-img {
        font-size: 1.125rem;
        text-anchor: middle;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }

      @media (min-width: 768px) {
        .bd-placeholder-img-lg {
          font-size: 3.5rem;
        }
      }

      body {
        padding-top: 5rem;
      }
      .starter-template {
        padding: 3rem 1.5rem;
        text-align: center;
      }
    </style>

  </head>
  <body>
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <a class="navbar-brand" href="#">AvlLab</a>
      <button class="navbar-toggler" type="button" data-toggle="collapse"
          data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault"
              aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="navbarsExampleDefault">
        <ul class="navbar-nav mr-auto">
        <li class="nav-item">
          <a class="nav-link" href="picsureui">PIC-SURE UI</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="transmart">i2b2/tranSmart</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="psamaui">PSAMA UI</a>
        </li>
        </ul>
      </div>
    </nav>

  <main role="main" class="container">

    <div class="starter-template">
      <h2>PIC-SURE Reference Implementation</h2>
      <p class="lead">This site is demonstrating the capabilities of the
      <a href="https://github.com/hms-dbmi/pic-sure-i2b2-transmart" target="_githubWin">pic-sure-i2b2-transmart docker stack</a>.</p>
    </div>

    <div>
      <br />
      <table class="table">
      <thead>
        <tr>
        <th>Service</th>
        <th>Docker Tag</th>
        <th>Uptime</th>
        </tr>
      </thead>
      <tbody>
        ${SERVICE_LIST}
      </tbody>
      </table>
    </div>

  </main><!-- /.container -->

  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

  </body>
</html>
EOP

docker cp /tmp/about pic-sure-i2b2-transmart_httpd_1:/usr/local/apache2/htdocs/about.html
