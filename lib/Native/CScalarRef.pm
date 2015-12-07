# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use v6;
use nqp;
use NativeCall;

class CScalarRef {
    has $.ptr;
    has $.raw;

    method FETCH { $!raw.AT-POS(0) }
    method STORE(\value) { $!raw.ASSIGN-POS(0, value) }

    method new(Mu:D \ptr where .REPR eq 'CPointer') {
        once {
            nqp::loadbytecode("nqp.{ $*VM.precomp-ext }");
            EVAL q:to/__END__/, :lang<nqp>;
            my $FETCH := nqp::getstaticcode(-> $cont {
                my $var := nqp::p6var($cont);
                nqp::decont(nqp::findmethod($var,'FETCH')($var));
            });

            my $STORE := nqp::getstaticcode(-> $cont, $value {
                my $var := nqp::p6var($cont);
                nqp::findmethod($var, 'STORE')($var, $value);
                Mu;
            });

            my $pair := nqp::hash('fetch', $FETCH, 'store', $STORE);
            nqp::setcontspec(CScalarRef,  'code_pair', $pair);
            Mu;
            __END__
        }

        my \scalar-type = ptr.?of;
        die "Cannot create CScalarRef from untyped pointer type { ptr.^name }"
            if scalar-type === Nil;
        die "Cannot create CScalarRef for type { scalar-type.^name }"
            unless scalar-type.REPR eq any <P6int P6num>;
        die "Cannot create CScalarRef from null pointer"
            if nqp::unbox_i(ptr) == 0;

        my \array-type = CArray[scalar-type];
        my \raw = nqp::nativecallcast(array-type, array-type, nqp::decont(ptr));
        my \ref = nqp::create(CScalarRef);

        nqp::bindattr(ref, CScalarRef, '$!raw', raw);
        nqp::bindattr(ref, CScalarRef, '$!ptr', ptr);

        ref;
    }
}
