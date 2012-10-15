//= require library/image

var gadget = (function declare_gadget (sorts) {
  var that = function initialize_photo(parent, options) {
    options = options || {};
    // TODO bettar duplication and sparated rendering support
    options.parent = parent || '#gadgets';
    options.data = options.data || {};
    return observable.call($.extend(options, inherit(gadget)));
  }, id = 0,
  gadget = {
    show: function() {
      !this.element && control.create.call(this);
      this.element.css(configuration.size).fadeIn();
      return this;
    },
    dispatch: function(name, event) {
      handlers[name] && handlers[name].call(this, event);
      return this;
    },
    listen: function (name, callback) {
      if (handlers.name) throw 'Listener already defined for ' + name;
      handlers[name] = callback;
      return this;
    },
    tie: function (photo_id) {
      var photo, subscription;
      if (this.tied) console.error('Gadget ', this.key, ' already tied');

      photo = this.photo;
      photo._id = photo_id;

      (!photo.specification) && (photo.specification = window.specification());

      photo.specification.subscribe('paper', view.subscriptions.paper);
      photo.subscribe('product_id', view.subscriptions.size );
      photo.subscribe('count'     , view.subscriptions.count);
      photo.gadget = photo.specification.gadget = this;


      // TODO Better proxy binding on event bindings
      bound = {}
      for (property in view) {
        if ($.type(view[property]) == 'function')
          bound[property] = $.proxy(view[property], this);
      }

      this.view = rivets.bind(this.element, {
          photo: photo,
          specification: photo.specification,
          gadget: observable.call(bound)
      });

      // Save changes when relavant data changes
      // TODO better change event support on record
      subscription = function(){ setTimeout(function(){ photo.save(); }, 500); };
      photo.subscribe('product_id', subscription);
      photo.subscribe('count', subscription);
      photo.specification.subscribe('paper', subscription);

      // TODO Make rivets view.sync work!
      this.update();

      this.tied = true;
    },
    // TODO Make rivets view.sync work!
    update: function () {
      var photo = this.photo
      photo.count = photo.count
      photo.product_id = photo.product_id
      photo.specification && (photo.specification.paper = photo.specification.paper)
    },
    duplicate: function () {
      // TODO less memory leaking copy
      var options = {
          data: {
            source: this.image.source(),
            title : this.data.title
          },
          orientation: this.orientation,
          parent: this.element,
          render: function (template) {
            this.element = $($.jqote(template, this.data));
            this.parent.after(this.element);
            this.element.addClass(this.orientation + " loaded");
          }
        },
        gadget = that(this.element, options), photo = this.photo.json();

      // Create a brand new model
      gadget.photo = window.photo(photo);
      // TODO copy automatically (implement nested attributes for has_one)
      gadget.photo.specification = window.specification(this.photo.specification.json());

      photo._id = null;
      delete photo._id;

      gadget.photo.route = this.photo.route;
      gadget.photo.width = this.photo.width;
      gadget.photo.height = this.photo.height;

      // Force new element criation
      gadget.element = null;
      delete gadget.element;

      gadget.tied = false;

      this.dispatch('duplicated', gadget);
      return gadget;
    },
    crop: function() {
      var dimensions    = this.photo.product[this.orientation + "_dimensions"],
          photo_height  = this.photo.height,
          photo_width   = this.photo.width,
          canvas_ratio  = this.orientation == "vertical" ? dimensions.width / dimensions.height : dimensions.height / dimensions.width, // inverso deixa borda
          canvas_scale  = Math.min(250 / dimensions.width, 250 / dimensions.height),
          canvas_width  = Math.round(canvas_scale * dimensions.width ),
          canvas_height = Math.round(canvas_scale * dimensions.height),
          img_ratio     = this.orientation == "vertical" ? photo_width / photo_height : photo_height / photo_width, // inverso deixa borda
          img_scale     = img_ratio > canvas_ratio ?
                            Math.min(250 / photo_width, 250 / photo_height) :
                            Math.max(canvas_width / photo_width, canvas_height / photo_height),
          canvas        = this.element.find('.canvas'),
          image         = canvas.find('.image'),
          img           = image.find('img'),
          left          = 0,
          top           = 0,
          cropped_height,
          cropped_width,
          canvas_height,
          canvas_width,
          canvas_left,
          canvas_top,
          img_height,
          img_width,
          img_left,
          img_top,
          product_dimensions;


      img_width  = Math.round(img_scale * photo_width );
      img_height = Math.round(img_scale * photo_height);

      img_left = (canvas_width - img_width) / 2;
      img_top  = (canvas_height - img_height) / 2;

      canvas_left = (this.element.innerWidth()  - canvas_width ) / 2;
      canvas_top  = (this.element.innerHeight() - canvas_height) / 2;

      canvas.css({width: canvas_width, height: canvas_height});
      canvas.css({top: canvas_top, left: canvas_left});
      image.css({width: canvas_width, height: canvas_height});
      img.css({left: img_left, top: img_top, height: img_height, width: img_width});

      product_dimensions = this.element.find(".dimension");
      product_dimensions.filter(".height").children(".count").html(dimensions.height);
      product_dimensions.filter(".width ").children(".count").html(dimensions.width );
    }
  },
  control = {
    create: function () {
      this.data = $.extend({
        id: id++,
        source: kuva.service.url + '/assets/blank.gif',
        title: 'Sumonando imagem'
      }, this.data);

      (this.render) || (this.render = control.render);
      this.parent && this.render(templates.gadget);

      this.element = $('#gadget-' + this.data.id);
      this.element.find("[rel=tooltip]").tooltip();
      this.image = library.image(this.element.find('img'), this.data.title);
      this.upload_bar = this.element.find('.upload.bar');
      this.thumbnail_bar = this.element.find('.thumbnail.bar');
      this.orientation || (this.orientation = "vertical");

      delete this.render;
    },
    render: function (template) {
      $(this.parent).jqoteapp(templates.gadget, this.data);
    },
    defaultize: function() {
      var element  = this.element,
          photo    = this.photo,
          controls = element.find('.control'),
          canvas   = element.find('.canvas'),
          paper;

      element.addClass('controlable');

      // TODO clear timeouts upon confirmation
      setTimeout(function(){
        controls.tooltip('destroy');

        $("                                                                                                         \
          <div class=\"tooltip left\" id=\"tooltip-size\">                                                          \
            <div class=\"tooltip-arrow\"></div>                                                                     \
            <div class=\"tooltip-inner\">                                                                           \
              TAMANHO<br /><small>Selecione o tamanho<br />da impressão final<br />que você deseja.</small>         \
            </div>                                                                                                  \
          </div>                                                                                                    \
        ").appendTo(canvas).delay(0).fadeTo('fast', 0.8);

        $("                                                                                                         \
          <div class=\"tooltip right\" id=\"tooltip-paper\">                                                        \
            <div class=\"tooltip-arrow\"></div>                                                                     \
            <div class=\"tooltip-inner\">                                                                           \
              PAPEL<br /><small>Você pode escolher<br />entre as opções<br />FOSCO e BRILHANTE.</small>             \
            </div>                                                                                                  \
          </div>                                                                                                    \
        ").appendTo(canvas).delay(700).fadeTo('fast', 0.8);

        $("                                                                                                         \
          <div class=\"tooltip bottom\" id=\"tooltip-count\">                                                       \
            <div class=\"tooltip-arrow\"></div>                                                                     \
            <div class=\"tooltip-inner\">                                                                           \
              QUANTIDADE<br /><small>Escolha quantas cópias de cada<br />foto que você quer revelar.</small>        \
            </div>                                                                                                  \
          </div>                                                                                                    \
        ").appendTo(canvas).delay(1400).fadeTo('fast', 0.8);

      }, 700);

    }
  },
  handlers = {
    loadstart: function reader_loadstart (event) {
      this.element.addClass('reading');
    },
    loadend: function reader_loadend (event) {
      this.thumbnail_bar.updated = (new Date()).getTime();
      this.orientation  = event.width < event.height ? "vertical" : "horizontal";
      this.photo.height = event.height;
      this.photo.width  = event.width;

      this.crop();
      this.element.addClass(this.orientation);

      if (event.default)
        control.defaultize.call(this);
      else
        this.element.removeClass('reading').addClass('thumbnailing');

      if (event.file) {
        this.image.title(event.file.name);
        this.data.title = event.file.name;
      }
    },
    thumbnailing: function thumbnailer_thumbnailing (event) {
      var percentage = Math.round(100 - (event.parsed / event.total) * 100), now = (new Date()).getTime();

      if (now - this.thumbnail_bar.updated > 200) {
        this.thumbnail_bar.animate({width: percentage + '%'}, 1000, 'linear');
        this.thumbnail_bar.updated = now;
      }
    },
    encoding: function thumbnailer_encoding (event) {
      this.thumbnail_bar.animate({width: '0%'});
    },
    thumbnailed: function thumbnailer_thumbnailed (event) {
      var gadget = this;

      this.thumbnail_bar.animate({width: '0%'}, 1000, 'linear', function () {
        gadget.image.hide();

        // TODO Fix in a better way the hide bug on webkit browsers
        setTimeout(function () {
          var prefix = "data:image/jpg;base64,";

          gadget.element.addClass('loaded').removeClass('thumbnailing');
          gadget.image.source(prefix + event.base64).show('slow', function () {
            gadget.thumbnail_bar.hide();
          }, 1)
        });

        // TODO resizer.unload();
        gadget.thumbnailed && gadget.thumbnailed();   // Execute callback if any
      });

    },
    upload: function upload_start (event) {
      // TODO rivetize
      this.uploading = true;
      // TODO when rivetized, this can be removed
      this.element.addClass('uploading');
    },
    uploading: function upload_progress (event) {
      var percentage = Math.round(100 - ((event.loaded / event.total) * 100));

      this.upload_bar.animate({width: percentage + '%'}, 1000, 'linear');
    },
    uploaded: function upload_complete(event) {
      var gadget = this;

      // TODO rivetize
      gadget.uploading = false;
      gadget.uploaded  = true;

      this.upload_bar.animate({width: '0%'}, 1000, 'linear', function () {
        // TODO when rivetized, this can be removed
        gadget.element.removeClass('uploading').addClass('uploaded');
      });
    }
  },
  view = {
    subscriptions: {
      count: function photo_count (value) {
        value = +value;

        var element = this.gadget.element;

        if (value == 1) element.find(".canvas .control.count:first").addClass   ("hideable");
        else            element.find(".canvas .control.count:first").removeClass("hideable");

        if (value == 0) element.addClass   ("zero");
        else            element.removeClass("zero");

        if (this.count == 1) element.find(".canvas .control.count .subcontrol.minus").html("-");
        if (value      == 1) element.find(".canvas .control.count .subcontrol.minus")
                               .html("<span style='font-size: 0.7em; position:relative; top: -2px;'>&times;</span>");
      },
      paper: function specification_paper (value) {
        this.gadget.element.find(".canvas .control.paper").data('title',"Papel "+specification.paper[value]+"<br /><small>clique para alterar</small>").tooltip('destroy').tooltip();
        this.gadget.element.removeClass("paper-" + this.paper).addClass("paper-" + value);
      },
      size: function photo_product_id (value) {
        var selected, current, width, height,
            gadget = this.gadget;

        products = window.product.where({id: [value, this.product_id]});

        if ( products[0]._id !== this.product_id )
          products.reverse();

        current  = products.shift();
        selected = products.shift() || current;
        this.product = selected;

        gadget.element.removeClass("size-" + current.name).addClass("size-" + selected.name);

        gadget.crop();
      }
    },
    decrement: function() { this.photo.count--; },
    increment: function() { this.photo.count++; },
    paperize: function() {
      var control = this.element.find(".canvas .control.paper");
      for ( paper in specification.paper )
        if (this.photo.specification.paper != paper ) {
          control.tooltip("destroy")
          this.photo.specification.paper = paper;
          control.tooltip("show");
          return;
        }
    },
    duplicate: gadget.duplicate,
    sizeize: function() {
      var element = this.element,
          photo   = this.photo,
          close   = function() {
            element.children(".modal").remove();
            element.removeClass("sizing");
          };


      if (element.children(".modal").length) {
        photo.product_id = photo.product_id;
        close();
        return;
      }

      element.addClass("sizing");
      element.append(templates.modal);

      rivets.bind(this.element, { size: observable.call({
        change: function(event) {
          photo.product_id = $(event.currentTarget).data("product-id");
          close();
        },
        close: close,
        products: _.map(product.all(),function(product){
          // TODO stop creating products and do not reobserve
          return observable.call($.extend({}, product, {
            option: function() {
              return product.vertical_dimensions.width    +
                     "<span class=\"times\">×</span>"     +
                       product.vertical_dimensions.height +
                     "<span class=\"unit\">cm</span>"     ;
            }
          }));
        })
      })});
    }
  },



  configuration = {
    size: { height: 250, width: 250 }
  };


  /*, TODO configuration = {
     resizer: {
     thumbnailing: handlers.thumbnailing,
     thumbnailed: handlers.thumbnailed,
     }
   }, resizer = image(null, configuration.resizer); */

  var templates = {
    gadget: null,
    modal : null
  };

  function initialize() {
    templates.gadget = $.jqotec('#gadget');
    templates.modal  = $.jqotec("                                                                                                        \
      <div class=\"modal modal-size\">                                                                                                   \
        <div class=\"title\">Escolha um tamanho:</div>                                                                                   \
        <div class=\"sizes\">                                                                                                            \
          <div data-each-product=\"size.products\">                                                                                      \
            <a class=\"size selected\" href=\"javascript:void(0);\" data-data-product-id=\"product.id\" data-on-click=\"size.change\" data-html=\"product.option\"></a>                                                                                                        \
          </div>                                                                                                                         \
        </div>                                                                                                                           \
        <a class=\"back\" href=\"javascript:void(0);\" data-on-click=\"size.close\">← voltar</a>                                         \
      </div>                                                                                                                             \
    ");
  };

  $(initialize);

  return that;
}).call(kuva, kuva.fn.sorts);
