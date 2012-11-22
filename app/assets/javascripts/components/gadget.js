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
    listeners: {},
    show: function (delay) {
      !this.element && control.create.call(this);
      // this.element.css(configuration.size).fadeIn();
      return this.element.css(configuration.size).show(delay).promise();
    },
    dispatch: function(name, event) {
      var listeners = gadget.listeners[name] || [],
                  i = listeners.length;

      try {
        while(i--) listeners[i].call(this, event);
        handlers[name] && handlers[name].call(this, event);
      }
      catch(e) {
        console.error(e.message+ " " + e + " on listener " + listeners[i] + "\n " + e.stack);
        throw e.message + " " + e + " on listener " + listeners[i] + "\n " + e.stack;
        return false;
      }
    },
    listen: function (name, listener) {
      gadget.listeners[name] || (gadget.listeners[name] = []);
      if (gadget.listeners[name].indexOf(listener) != -1)
        throw 'Listener already defined for ' + name;
      gadget.listeners[name].push(listener);
      return this;
    },
    tie: function (photo_id) {
      var self = this;
      setTimeout(function() {
        var photo, subscription;
        if (self.tied) console.error('Gadget ', self.key, ' already tied');

        photo = self.photo;
        photo._id = photo_id;

        (!photo.specification) && (photo.specification = window.specification());

        photo.specification.subscribe('paper', view.subscriptions.paper);
        photo.subscribe('product_id', view.subscriptions.size  );
        photo.subscribe('count'     , view.subscriptions.count );
        photo.subscribe('border'    , view.subscriptions.border);
        photo.subscribe('margin'    , view.subscriptions.margin);
        photo.gadget = photo.specification.gadget = self;


        // TODO Better proxy binding on event bindings
        bound = {};
        for (property in view) {
          if ($.type(view[property]) == 'function')
            bound[property] = $.proxy(view[property], self);
        }

        self.view = rivets.bind(self.element, {
            photo: photo,
            specification: photo.specification,
            gadget: observable.call(bound)
        });

        self.element.find("[rel=tooltip]").tooltip();

        photo.subscribe(              'dirty', function(prop, dirty){ dirty && setTimeout(function(){ photo.save() }, 500); });
        photo.specification.subscribe('dirty', function(prop, dirty){ if(dirty){ photo.dirty = true; this.dirty = false; } });

        self.tied = true;

        self.update();

      }, 0);
    },
    // TODO Make rivets view.sync work!
    update: function () {
      this.photo.publish();
      this.photo.specification.publish();
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
      photo._id = null;
      delete photo._id;
      gadget.photo = window.photo(photo);

      // TODO copy automatically (implement nested attributes for has_one)
      gadget.photo.specification = window.specification(this.photo.specification.json());

      gadget.photo.route  = this.photo.route;
      gadget.photo.width  = this.photo.width;
      gadget.photo.height = this.photo.height;

      // Force new element criation
      gadget.element = null;
      delete gadget.element;

      gadget.tied = false;

	  if (gadget.photo.image) {
        this.element.find('.pomp.info-pomp:first').html();
		gadget.photo.image.name = gadget.photo.image.name;
	  }

      this.dispatch('duplicated', gadget);

      return gadget;
    }
  },
  control = {
    create: function () {
      this.data = $.extend({
        id: id++,
        source: kuva.service.url + '/assets/blank.gif',
        title: 'Gerando miniatura...'
      }, this.data);

      (this.render) || (this.render = control.render);
      this.parent && this.render(templates.gadget);

      this.element       = $('#gadget-' + this.data.id);
      this.image         = library.image(this.element.find('.image img'), this.data.title); // TODO REMOVE title
      this.original_image= library.image(this.element.find('.original-image img'), this.data.title); // TODO best support for original image
      this.upload_bar    = this.element.find('.upload.bar   ');
      this.thumbnail_bar = this.element.find('.thumbnail.bar');
      this.orientation || (this.orientation = "vertical");

      // TODO automatically forward thos property to view layer
      this.element.find('.pomp.info-pomp:first').html(this.data.title);

      delete this.render;
    },
    render: function (template) {
      $(this.parent).jqoteapp(templates.gadget, this.data);
    },
    defaultize: function() {
      var element  = this.element,
          photo    = this.photo,
          controls = element.find('.control'),
          canvas   = element.find('.canvas '),
          paper;

      this.default = true;

      element.addClass('controlable');

      // TODO clear timeouts upon confirmation
      setTimeout(function(){
        controls.filter('.count, .margin, .border').tooltip('destroy');

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

        $("                                                                                                         \
          <div class=\"tooltip left\" id=\"tooltip-margin\">                                                        \
            <div class=\"tooltip-arrow\"></div>                                                                     \
            <div class=\"tooltip-inner\">                                                                           \
              MARGEM<br /><small>Adicione ou remova uma margem<br />branca ao redor da foto.</small>                \
            </div>                                                                                                  \
          </div>                                                                                                    \
        ").appendTo(canvas).delay(2100).fadeTo('fast', 0.8);

        $("                                                                                                         \
          <div class=\"tooltip left\" id=\"tooltip-border\">                                                       \
            <div class=\"tooltip-arrow\"></div>                                                                     \
            <div class=\"tooltip-inner\">                                                                           \
              CORTE<br /><small>Encaixa a imagem na proporção do papel de<br />forma regular, dependendo do tamanho.<br />Clique para testar</small> \
            </div>                                                                                                  \
          </div>                                                                                                    \
        ").appendTo(canvas).delay(2800).fadeTo('fast', 0.8);

      }, 700);

    }
  },
  handlers = {
    loadstart: function reader_loadstart (event) {
      this.element.addClass('reading');
    },
    loadend: function reader_loadend (event) {
      this.thumbnail_bar.updated = this.upload_bar.updated = (new Date()).getTime();
      this.orientation  = event.width < event.height ? "vertical" : "horizontal";
      this.photo.height = event.height;
      this.photo.width  = event.width;

      scalation.crop(this);

      this.element.addClass(this.orientation);

      if (event.default) {
        control.defaultize.call(this);
        return;
      }

      resolution.check(this);

      this.element.removeClass('reading').addClass('thumbnailing');

      if (event.file) {
        // TODO create association photo.image & rivetize!
        this.element.find('.pomp.info-pomp:first').html(event.file.name);
        this.image.title(event.file.name);
        this.data.title = event.file.name;
        this.original_image.title("Esta parte da imagem será cortada.");
      }
    },
    thumbnailing: function thumbnailer_thumbnailing (event) {
      var percentage = 100-event.percentage, now = (new Date()).getTime();

      if (now - this.thumbnail_bar.updated > 200) {
        this.thumbnail_bar.stop().animate({width: percentage + '%'}, 500, 'linear');
        this.thumbnail_bar.updated = now;
      }
    },
    encoding: function thumbnailer_encoding (event) {
      this.thumbnail_bar.css({width: '0%'});
    },
    thumbnailed: function thumbnailer_thumbnailed (event) {
      var gadget = this;

      this.thumbnail_bar.stop().animate({width: '0%'}, 500, function(){
        gadget.image.hide();
        gadget.original_image.hide();

        // TODO Fix in a better way the hide bug on webkit browsers
        setTimeout(function () {
          var prefix = "data:image/jpg;base64,";

          gadget.element.addClass('loaded').removeClass('thumbnailing');
          gadget.image.source(prefix + event.base64).show('slow', function () {
            gadget.thumbnail_bar.hide();
          }, 1);
          // TODO best support for original image
          gadget.original_image.source(prefix + event.base64).show('slow', function () {
            gadget.thumbnail_bar.hide();
          }, 1);
        });
      });

      // TODO resizer.unload();
      gadget.thumbnailed && gadget.thumbnailed();   // Execute callback if any

    },
    upload: function upload_start (event) {
      // TODO rivetize
      this.uploading = true;
      // TODO when rivetized, this can be removed
      this.element.addClass('uploading');
    },
    uploading: function upload_progress (event) {
      var percentage = Math.round(100 - ((event.loaded / event.total) * 100)), now = (new Date()).getTime();

      if (now - this.upload_bar.updated > 200) {
        this.upload_bar.stop().animate({width: percentage + '%'}, 1000, 'linear');
        this.upload_bar.updated = now;
      }
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
    },
    reader_errored: function reader_errored(event) {
      var element = this.element;
      element.addClass('errored reader-errored');
      element.find('.image:first').append($(
        '<div class="error-message">'                                 +
        '  Não conseguimos ler a imagem'                              +
        '  <div class="file-name">' + this.files[0].name + '</div>'   +
        '  Este arquivo não será enviado.'                            +
        '</div>'
      ));

	  // TODO automatically forward thos property to view layer
      this.element.find('.pomp.info-pomp:first').html('');
    },
    thumbnailer_errored: function reader_errored(event) {
      var element = this.element;
      element.addClass('errored thumbnailer-errored');
      element.find('.image:first').append($(
        '<div class="error-message">'                                                     +
        '  Não conseguimos gerar a miniatura da imagem'                                   +
        '  <div class="file-name">' + this.files[0].name + '</div>'                       +
        '  Este arquivo SERÁ enviado, você ainda pode definir como vai querer revelá-lo.' +
        '</div>'
      ));
    }
  },
  view = {
    subscriptions: {
      count: function photo_count (prop, value, old) {
        value = +value;

        var element = this.gadget.element;

        if (value == 1) element.find(".canvas .control.count:first").addClass   ("hideable");
        else            element.find(".canvas .control.count:first").removeClass("hideable");

        if (value == 0) element.addClass   ("zero");
        else            element.removeClass("zero");

        if (old   == 1) element.find(".canvas .control.count .subcontrol.minus").html("-");
        if (value == 1) element.find(".canvas .control.count .subcontrol.minus")
                          .html("<span style='font-size: 0.7em; position:relative; top: -2px;'>&times;</span>");
      },
      paper: function specification_paper (prop, value, old) {
        this.gadget.element.find(".canvas .control.paper").data('title',"Papel "+specification.paper[value]+"<br /><small>clique para alterar</small>").tooltip('destroy').tooltip();
        this.gadget.element.removeClass("paper-" + old).addClass("paper-" + value);
      },
      size: function photo_product_id (prop, value, old) {
        var selected, current, width, height,
            gadget = this.gadget;


        products = window.product.where({id: [value, old]});

        if ( products[0]._id !== old )
          products.reverse();

        current  = products.shift();
        selected = products.shift() || current;

        // TOOD implement lazy load
        WatchJS.noMore = true;
        this.product = selected;
        WatchJS.noMore = false;

        gadget.element.removeClass("size-" + current.name).addClass("size-" + selected.name);

        scalation.crop(gadget);
        resolution.check(gadget);
      },
      border: function photo_border(prop, border, old) {
        var gadget = this.gadget;

        gadget.element.find(".canvas .control.border").data('title',
          border ? 'Sem corte <small>(clique para cortar)</small>' : 'Corte ativo <small>(clique para não cortar)</small>'
        ).tooltip('destroy').tooltip();

        // TODO fix this: setting timeout because we need the new value of gadget.photo.border inside crop()
        scalation.crop(gadget);
      },
      margin: function photo_margin(prop, margin, old) {
        // TODO fix this: setting timeout because we need the new value of gadget.photo.border inside crop()
        var gadget  = this.gadget,
            element = gadget.element;

        element[margin ? 'addClass' : 'removeClass']('margin');
        element.find(".canvas .control.margin:first")[margin ? 'addClass' : 'removeClass']('active');

        scalation.crop(gadget);
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
    borderize: function() {
      var control = this.element.find(".canvas .control.border");
      control.tooltip("destroy");
      this.photo.border = !this.photo.border;
      control.tooltip("show");
    },
    marginize: function() {
      this.photo.margin = !this.photo.margin;
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
        close();
        return;
      }

      element.addClass("sizing");
      element.append(templates.modal);

      rivets.bind(this.element.find('.modal-size:first'), { size: observable.call({
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




  manipulable = function(name) {
    var original = this;
    return function() {
      var gadget = arguments[0],
          args   = arguments,
          manipulation;
      gadget.manipulations || (gadget.manipulations = {});
      gadget.manipulations[name] || (gadget.manipulations[name] = {fn:original, args: args});
      gadget.manipulated && clearTimeout(gadget.manipulated);
      gadget.manipulated = setTimeout(function(){
        for (name in gadget.manipulations) {
          manipulation = gadget.manipulations[name];
          manipulation.fn.apply(gadget, manipulation.args);
        };
        gadget.manipulations = {};
      }, 100);
    };
  },


  resolution = {
    // must be in descendent order by ppi
    ranges: [
      { ppi: 130, quality: 'good'    },
      { ppi: 100, quality: 'average' },
      { ppi:   0, quality: 'bad'     }
    ],
    unit: 'centimeters',
    check: manipulable.call(function check_resolution(gadget) {
      var photo   = gadget.photo,
          product = photo.product,
          quality, pomp;

      if (gadget.default || (!photo.width && !photo.height)) return;

      quality = resolution.quality(photo.width * photo.height, product.dimensions);
      pomp    = gadget.element.find('.canvas .resolution-pomp:first');

      pomp.remove();

      switch(quality) {
        case 'good':
          break;
        case 'bad':
          gadget.element.find('.canvas:first').append($('<div class="pomp resolution-pomp bad" data-title="Resolução não recomendada<br /><small>A resolução desta foto ('+photo.width+'x'+photo.height+') pode prejudicar a qualidade da imagem para o tamanho '+ product.dimensions[0] +'x'+ product.dimensions[1] +' cm. Aconselhamos escolher um tamanho menor.</small>">&bull;</div>').tooltip({placement: 'bottom'}));
          break;
        case 'average':
          gadget.element.find('.canvas:first').append($('<div class="pomp resolution-pomp average" data-title="Resolução aceitavel<br /><small>A resolução desta foto ('+photo.width+'x'+photo.height+') pode prejudicar a qualidade da imagem para o tamanho '+ product.dimensions[0] +'x'+ product.dimensions[1] +' cm, mas ainda é aceitável.</small>">&bull;</div>').tooltip({placement: 'bottom'}));
          break;
      };

    }, 'check_resolution'),
    quality: function quality_resolution(pixels, dimensions, unit) {
      var ppi, range;

      unit || (unit = resolution.unit);
      if ( !pixels ) throw "Pixels cannnot be " + pixels;
      if ( !$.isArray(dimensions) || dimensions.length != 2 ) throw "Dimensions should be like [10, 15]";

      ppi = Math.sqrt( +pixels / (+dimensions[0] * +dimensions[1]) );

      switch(unit) {
        case 'centimeters':
          ppi = ppi * 2.5;
          break;
      };

      // TODO accept ranges in any order
      for (var i=0; i < resolution.ranges.length; i++) {
        range = resolution.ranges[i];
        if (ppi > range.ppi) return range.quality;
      };
    }
  },


  scalation = {
    crop: manipulable.call(function(gadget) {
      var dimensions    = gadget.photo.product[gadget.orientation + "_dimensions"],
          photo_height  = gadget.photo.height,
          photo_width   = gadget.photo.width,
          canvas_ratio  = (gadget.orientation == "vertical") ?
                            dimensions.width  / dimensions.height :
                            dimensions.height / dimensions.width,
          canvas_scale  = Math.min(configuration.size.width / dimensions.width, configuration.size.height / dimensions.height),
          canvas_width  = Math.round(canvas_scale * dimensions.width ),
          canvas_height = Math.round(canvas_scale * dimensions.height),
          img_ratio     = (gadget.orientation == "vertical") ?
                            photo_width  / photo_height :
                            photo_height / photo_width,
          total_margin  = +gadget.photo.margin * configuration.margin.width * 2,
          img_scale     = (img_ratio > canvas_ratio) && !gadget.photo.border ?
                            Math[!gadget.photo.border ? 'min' : 'max'](configuration.size.width / photo_width, configuration.size.height / photo_height) :
                            Math[!gadget.photo.border ? 'max' : 'min'](canvas_width / photo_width, canvas_height / photo_height),
          canvas        = gadget.element.find('.canvas'),
          image         = canvas.find('.image, .original-image'),
          img           = canvas.find('.image img, .original-image img'),
          left          = 0,
          top           = 0,
          canvas_left,
          canvas_top,
          img_height,
          img_width,
          img_left,
          img_top,
          product_dimensions;

      // margin only affects the image wrapper and the img itself

      image_width  = canvas_width  - total_margin;
      image_height = canvas_height - total_margin;

      img_width  = Math.round(img_scale * photo_width ) - total_margin;
      img_height = Math.round(img_scale * photo_height) - total_margin;

      img_left = (canvas_width  - img_width ) / 2 - total_margin / 2;
      img_top  = (canvas_height - img_height) / 2 - total_margin / 2;

      canvas_left = (gadget.element.innerWidth()  - canvas_width ) / 2;
      canvas_top  = (gadget.element.innerHeight() - canvas_height) / 2;

      canvas.css({width: canvas_width, height: canvas_height});
      canvas.css({top: canvas_top, left: canvas_left});
      image.css({width: image_width, height: image_height});
      img.css({left: img_left, top: img_top, height: img_height, width: img_width});

      product_dimensions = gadget.element.find(".dimension");

      // TODO rivetize !!
      product_dimensions.filter(".height").children(".count").html(dimensions.height);
      product_dimensions.filter(".width ").children(".count").html(dimensions.width );
    }, 'crop')
  },



  configuration = {
    size  : { height: 250, width: 250 },
    margin: { width: 4 }
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
            <a class=\"size selected\" href=\"javascript:void(0);\" data-data-product-id=\"product._id\" data-on-click=\"size.change\" data-html=\"product.option\"></a>                                                                                                        \
          </div>                                                                                                                         \
        </div>                                                                                                                           \
        <a class=\"back\" href=\"javascript:void(0);\" data-on-click=\"size.close\">← voltar</a>                                         \
      </div>                                                                                                                             \
    ");
  };

  $(initialize);

  that.listen = gadget.listen;
  that.handlers = handlers;


  return that;
}).call(kuva, kuva.fn.sorts);
