/*
** mrb_mrmagick.c - Mrmagick class
**
** Copyright (c) Junichi Kajiwara 2015
**
** See Copyright Notice in LICENSE
*/

#include "mruby.h"
#include "mruby/data.h"
#include "mrb_mrmagick.h"

#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  char *str;
  int len;
} mrb_mrmagick_data;

static const struct mrb_data_type mrb_mrmagick_data_type = {
  "mrb_mrmagick_data", mrb_free,
};

static mrb_value mrb_mrmagick_init(mrb_state *mrb, mrb_value self)
{
  mrb_mrmagick_data *data;
  char *str;
  int len;

  data = (mrb_mrmagick_data *)DATA_PTR(self);
  if (data) {
    mrb_free(mrb, data);
  }
  DATA_TYPE(self) = &mrb_mrmagick_data_type;
  DATA_PTR(self) = NULL;

  mrb_get_args(mrb, "s", &str, &len);
  data = (mrb_mrmagick_data *)mrb_malloc(mrb, sizeof(mrb_mrmagick_data));
  data->str = str;
  data->len = len;
  DATA_PTR(self) = data;

  return self;
}

static mrb_value mrb_mrmagick_hello(mrb_state *mrb, mrb_value self)
{
  mrb_mrmagick_data *data = DATA_PTR(self);

  return mrb_str_new(mrb, data->str, data->len);
}

static mrb_value mrb_mrmagick_hi(mrb_state *mrb, mrb_value self)
{
  return mrb_str_new_cstr(mrb, "hi!!");
}

void mrb_mruby_mrmagick_gem_init(mrb_state *mrb)
{
    struct RClass *mrmagick_module;
    struct RClass *mrmagick;

    mrmagick_module = mrb_define_module(mrb, "Mrmagick");
    mrmagick = mrb_define_class_under(mrb, mrmagick_module, "Capi", mrb->object_class);

    mrb_define_method(mrb, mrmagick, "initialize", mrb_mrmagick_init, MRB_ARGS_REQ(1));
    mrb_define_method(mrb, mrmagick, "hello", mrb_mrmagick_hello, MRB_ARGS_NONE());
    mrb_define_class_method(mrb, mrmagick, "hi", mrb_mrmagick_hi, MRB_ARGS_NONE());
    DONE;
}

void mrb_mruby_mrmagick_gem_final(mrb_state *mrb)
{
}
