{
  services.kanata = {
    enable = true;
    keyboards = {
      victsing = {
        config = ''
          (defsrc
            esc
            `    1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
            lsft <    z    x    c    v    b    n    m    ,    .    /    rsft
          )

          (deflayer base
            esc
            `    1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]
            @ale @mou s    d    f    g    h    j    k    l    @sym @alq \    ret
            lsft lctl z    x    c    v    b    n    m    ,    .    /    rsft
          )

          (deflayer symbols
            _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            \    @bng @at  @car @and @pip home pgdn pgup end  _    _    _
            _    @pnd @dol @lpr @rpr `    left down up   rght _    '    _    _
            _    _    @prc @usc @str =    @til +    -    _    _    _    _
          )

          (deflayer mouse
            _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    @msu _    _    @mwl @mwd @mwu @mwr pp   _    _
            _    _    @msl @msd @msr _    _    mlft mrgt mmid prev next _    _
            _    _    _    _    _    _    _    _    mute vold volu del  _
          )

          (defalias
            usc (multi lsft -)
            bng (multi lsft 1)
            at  (multi lsft 2)
            pnd (multi lsft 3)
            dol (multi lsft 4)
            prc (multi lsft 5)
            car (multi lsft 6)
            and (multi lsft 7)
            str (multi lsft 8)
            lpr (multi lsft 9)
            rpr (multi lsft 0)
            pip (multi lsft \)
            til (multi lsft `)

            sym (tap-hold-press 200 200 ; (layer-while-held symbols))
            mou (tap-hold-release 200 200 a (layer-while-held mouse))
            ale (tap-hold-release 200 200 esc alt)
            alq (tap-hold-release 200 200 ' alt)

            msu (movemouse-accel-up 3 1000 1 5)
            msd (movemouse-accel-down 3 1000 1 5)
            msl (movemouse-accel-left 3 1000 1 5)
            msr (movemouse-accel-right 3 1000 1 5)

            mwu (mwheel-up 50 60)
            mwd (mwheel-down 50 60)
            mwl (mwheel-left 50 60)
            mwr (mwheel-right 50 60)
          )
        '';
        extraDefCfg = ''
          movemouse-inherit-accel-state yes
          movemouse-smooth-diagonals yes
        '';
      };
    };
  };
}
