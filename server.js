(function() {
  var HOST, PORT, SITE_ROOT, User, crypto, express, fs, jade, loadUser, mongoStore, mongoose, path, server, sys, url;
  crypto = require('crypto');
  sys = require("sys");
  url = require("url");
  path = require("path");
  fs = require("fs");
  require.paths.push('/usr/local/lib/node');
  express = require('express');
  jade = require('jade');
  mongoose = require('mongoose');
  mongoStore = require('connect-mongodb');
  HOST = "localhost";
  PORT = "8080";
  SITE_ROOT = process.cwd() + '/';
  server = express.createServer();
  server.configure(function() {
    server.set('views', __dirname);
    server.set('partials', __dirname);
    server.set('view engine', 'jade');
    server.use(express.logger());
    server.use(express.bodyDecoder());
    server.use(express.cookieDecoder());
    server.use(express.methodOverride());
    server.use(express.staticProvider(__dirname));
    return server.use(server.router);
  });
  server.configure('development', function() {
    var db_url;
    server.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
    db_url = 'mongodb://localhost:27017/test';
    server.use(express.session({
      key: 'a key',
      secret: 'secrets are no fun!',
      store: mongoStore({
        url: db_url
      })
    }));
    return mongoose.connect(db_url);
  });
  server.configure('production', function() {
    return express.errorHandler();
  });
  loadUser = function(req, res, next) {
    if (req.session.user_id) {
      return User.findById(req.session.user_id, function(user) {
        if (user) {
          req.currentUser = user;
          return next();
        } else {
          return res.redirect('/sessions/new');
        }
      });
    } else {
      return res.redirect('/sessions/new');
    }
  };
  User = new mongoose.Schema({
    email: {
      type: String,
      unique: true,
      set: this.toLower
    },
    hashed_password: {
      type: String,
      set: this.encryptPassword
    },
    salt: String
  });
  User.method('toLower', function(email) {
    return email.toLowerCase();
  });
  User.method('authenticate', function(plainText) {
    return this.encryptPassword(plainText) === this.hashed_password;
  });
  User.method('makeSalt', function() {
    return Math.round(new Date().valueOf() * Math.random()) + '';
  });
  User.method('encryptPassword', function(password) {
    return crypto.createHmac('sha1', this.salt).update(password).digest('hex');
  });
  mongoose.model('User', User);
  server.get('/', function(req, res) {
    return res.render('layout', {
      locals: {
        title: 'Home',
        content: res.partial('home')
      }
    });
  });
  server.get('/about', function(req, res) {
    return res.render('layout', {
      locals: {
        title: 'About',
        content: res.partial('about')
      }
    });
  });
  server.listen(PORT, HOST);
  sys.puts("Server running at " + HOST + ":" + PORT);
}).call(this);
