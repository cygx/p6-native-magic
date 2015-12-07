# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use v6;
use nqp;
use NativeCall;

use Native::CScalarRef;

sub prefix:<*>(Mu:D \ptr) is export {
    CScalarRef.new(ptr);
}

sub postfix:<*>(Mu:U \type) is export {
    -> Mu:D \value { nqp::box_i(nqp::unbox_i(value), Pointer[type]) }
}
