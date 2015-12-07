    use Native::LibC <calloc int>;
    use Native::Magic;

    my \p = (int*)( calloc(1, 4) );
    say *p;

    my $i := *p;
    $i = 42;

    say *p;
