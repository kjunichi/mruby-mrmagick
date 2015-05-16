#include <stdio.h>
#include "mruby.h"

	static mrb_value
mrb_mrmagick_test_mrmagick_setup(mrb_state *mrb, mrb_value self)
{
	return mrb_true_value();
}

	static mrb_value
mrb_mrmagick_test_mrmagick_cleanup(mrb_state *mrb, mrb_value self)
{
	return mrb_true_value();
}

	void
mrb_mruby_mrmagick_gem_test(mrb_state* mrb)
{
	struct RClass *mrmagick_test = mrb_define_module(mrb, "MRubyMrmagickTestUtil");
	mrb_define_class_method(mrb, mrmagick_test, "mrmagick_test_setup", mrb_mrmagick_test_mrmagick_setup, MRB_ARGS_NONE());
	mrb_define_class_method(mrb, mrmagick_test, "mrmagick_test_cleanup", mrb_mrmagick_test_mrmagick_cleanup, MRB_ARGS_NONE());
}
