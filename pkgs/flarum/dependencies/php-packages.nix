{composerEnv, fetchurl, fetchFromGitHub, fetchgit ? null, fetchhg ? null, fetchsvn ? null, noDev ? false}:

let
  packages = {
    "axy/backtrace" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "axy-backtrace-e0f806986db00190e567b0071c765bd792360f06";
        src = fetchurl {
          url = "https://api.github.com/repos/axypro/backtrace/zipball/e0f806986db00190e567b0071c765bd792360f06";
          sha256 = "0c24pc2djf7iyh118mmnnghl52yzrxxvkzvnzdr9ijhvlqfsy7rx";
        };
      };
    };
    "brick/math" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "brick-math-0ad82ce168c82ba30d1c01ec86116ab52f589478";
        src = fetchurl {
          url = "https://api.github.com/repos/brick/math/zipball/0ad82ce168c82ba30d1c01ec86116ab52f589478";
          sha256 = "04kqy1hqvp4634njjjmhrc2g828d69sk6q3c55bpqnnmsqf154yb";
        };
      };
    };
    "components/font-awesome" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-font-awesome-e6fd09f30f578915cc0cf186b0dd0da54385b6be";
        src = fetchurl {
          url = "https://api.github.com/repos/components/font-awesome/zipball/e6fd09f30f578915cc0cf186b0dd0da54385b6be";
          sha256 = "0rpwfxmigbcs3q70iq2k11lg31j56vjvla7f57wnsl7p6z6xn1x8";
        };
      };
    };
    "dflydev/dot-access-data" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-dot-access-data-f41715465d65213d644d3141a6a93081be5d3549";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-dot-access-data/zipball/f41715465d65213d644d3141a6a93081be5d3549";
          sha256 = "1vgbjrq8qh06r26y5nlxfin4989r3h7dib1jifb2l3cjdn1r5bmj";
        };
      };
    };
    "dflydev/fig-cookies" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-fig-cookies-ebe6c15c9895fc490efe620ad734c8ef4a85bdb0";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-fig-cookies/zipball/ebe6c15c9895fc490efe620ad734c8ef4a85bdb0";
          sha256 = "0nvnvf1lz8r5nc43g8jynjxjbsh6qxggnwhgikccqliagmm843ph";
        };
      };
    };
    "doctrine/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-cache-1ca8f21980e770095a31456042471a57bc4c68fb";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/cache/zipball/1ca8f21980e770095a31456042471a57bc4c68fb";
          sha256 = "1p8ia9g3mqz71bv4x8q1ng1fgcidmyksbsli1fjbialpgjk9k1ss";
        };
      };
    };
    "doctrine/dbal" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-dbal-c480849ca3ad6706a39c970cdfe6888fa8a058b8";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/dbal/zipball/c480849ca3ad6706a39c970cdfe6888fa8a058b8";
          sha256 = "15j98h80li6m1aj53p8ddy0lkbkanc5kdy6xrikpdd6zhmsfgq9k";
        };
      };
    };
    "doctrine/deprecations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-deprecations-612a3ee5ab0d5dd97b7cf3874a6efe24325efac3";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/deprecations/zipball/612a3ee5ab0d5dd97b7cf3874a6efe24325efac3";
          sha256 = "078w4k0xdywyb44caz5grbcbxsi87iy13g7a270rs9g5f0p245fi";
        };
      };
    };
    "doctrine/event-manager" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-event-manager-95aa4cb529f1e96576f3fda9f5705ada4056a520";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/event-manager/zipball/95aa4cb529f1e96576f3fda9f5705ada4056a520";
          sha256 = "0xi2s28jmmvrndg1yd0r5s10d9a0q6j2dxdbazvcbws9waf0yrvj";
        };
      };
    };
    "doctrine/inflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-inflector-f9301a5b2fb1216b2b08f02ba04dc45423db6bff";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/inflector/zipball/f9301a5b2fb1216b2b08f02ba04dc45423db6bff";
          sha256 = "1kdq3sbwrzwprxr36cdw9m1zlwn15c0nz6i7mw0sq9mhnd2sgbrb";
        };
      };
    };
    "doctrine/lexer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-lexer-c268e882d4dbdd85e36e4ad69e02dc284f89d229";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/lexer/zipball/c268e882d4dbdd85e36e4ad69e02dc284f89d229";
          sha256 = "12g069nljl3alyk15884nd1jc4mxk87isqsmfj7x6j2vxvk9qchs";
        };
      };
    };
    "dragonmantank/cron-expression" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dragonmantank-cron-expression-782ca5968ab8b954773518e9e49a6f892a34b2a8";
        src = fetchurl {
          url = "https://api.github.com/repos/dragonmantank/cron-expression/zipball/782ca5968ab8b954773518e9e49a6f892a34b2a8";
          sha256 = "18pxn1v3b2yhwzky22p4wn520h89rcrihl7l6hd0p769vk1b2qg9";
        };
      };
    };
    "egulias/email-validator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "egulias-email-validator-0dbf5d78455d4d6a41d186da50adc1122ec066f4";
        src = fetchurl {
          url = "https://api.github.com/repos/egulias/EmailValidator/zipball/0dbf5d78455d4d6a41d186da50adc1122ec066f4";
          sha256 = "00kwb8rhk1fq3a1i152xniipk3y907q1v5r3szqbkq5rz82dwbck";
        };
      };
    };
    "fig/http-message-util" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fig-http-message-util-9d94dc0154230ac39e5bf89398b324a86f63f765";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-message-util/zipball/9d94dc0154230ac39e5bf89398b324a86f63f765";
          sha256 = "1cbhchmvh8alqdaf31rmwldyrpi5cgmzgair1gnjv6nxn99m3pqf";
        };
      };
    };
    "filp/whoops" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "filp-whoops-c83e88a30524f9360b11f585f71e6b17313b7187";
        src = fetchurl {
          url = "https://api.github.com/repos/filp/whoops/zipball/c83e88a30524f9360b11f585f71e6b17313b7187";
          sha256 = "1gic15fav548z97yqsawwlmnkdwnrq36095218jzd9b4s8n4zn2g";
        };
      };
    };
    "flarum/approval" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-approval-c927947b7cd05ea927268ac45b5c821e6dd7d866";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/approval/zipball/c927947b7cd05ea927268ac45b5c821e6dd7d866";
          sha256 = "07d2z1dvllssnx23nfaidqshxi7xx880a23yh734hpqzi1c531wz";
        };
      };
    };
    "flarum/bbcode" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-bbcode-9d5fa06b18bf78c9d2f6e82d3904fff6e3fcb8a9";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/bbcode/zipball/9d5fa06b18bf78c9d2f6e82d3904fff6e3fcb8a9";
          sha256 = "0hcdpl3qxmxs92x5ald7grv5p7g5nq02srxgd5ks7aikw0rm2sh5";
        };
      };
    };
    "flarum/core" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-core-ce3bbf02f0f4dbb9cc56752c1c49a6c42b63f1fc";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/flarum-core/zipball/ce3bbf02f0f4dbb9cc56752c1c49a6c42b63f1fc";
          sha256 = "0jbsglil8krlg1xcb86r16v94gmqk8zkiyhynzqslz1bj0z1a4a5";
        };
      };
    };
    "flarum/emoji" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-emoji-b09f3ece759bba06f89d89e3f62c9ce65b35351e";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/emoji/zipball/b09f3ece759bba06f89d89e3f62c9ce65b35351e";
          sha256 = "1vdz4ck7xmqcmc95hs8ls54cqiwj697psj3iyhrnsn5kmryygb6y";
        };
      };
    };
    "flarum/flags" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-flags-941cc37719b6437eca09f03715a27793abe1fb48";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/flags/zipball/941cc37719b6437eca09f03715a27793abe1fb48";
          sha256 = "098j3six2jc8yzwgq5fvbp3yjgmxllgypl0yrlpdiy0zi9n1343c";
        };
      };
    };
    "flarum/lang-english" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-lang-english-7b1c2feb49f0b6707746907ca426dd309860b60f";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/lang-english/zipball/7b1c2feb49f0b6707746907ca426dd309860b60f";
          sha256 = "0a0lyybz190mgflg45bb3lbphpsy34nb4cbdh5m6hxad9lp05dlw";
        };
      };
    };
    "flarum/likes" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-likes-55dfbb535a18149cd0cca66703fd19da07cb3a36";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/likes/zipball/55dfbb535a18149cd0cca66703fd19da07cb3a36";
          sha256 = "19h9ikg9x5my52f2kgj31ddr9m0ngvxj83j1glr5cs7fvg476ndm";
        };
      };
    };
    "flarum/lock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-lock-3d48574c0ebdd3ef28d65fe4882d7af00797bce1";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/lock/zipball/3d48574c0ebdd3ef28d65fe4882d7af00797bce1";
          sha256 = "188pny0xb8qpa01npg2z6w1qf02bibidgrdyfxchjnkdhg8am7ib";
        };
      };
    };
    "flarum/markdown" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-markdown-2e3724c9c7b322b8af41fbddb73b0332cfbd16fc";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/markdown/zipball/2e3724c9c7b322b8af41fbddb73b0332cfbd16fc";
          sha256 = "0z130wigrz7w0z5v7937s7nd7z177slwj79s7id1mi2ckv4iihpy";
        };
      };
    };
    "flarum/mentions" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-mentions-8789becf13a5813d7e819d382568ab0880f5f9c7";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/mentions/zipball/8789becf13a5813d7e819d382568ab0880f5f9c7";
          sha256 = "0rfq2iygpq0ydza1idsp43spk4rmy4xj59rai2586yj9lx1a9j81";
        };
      };
    };
    "flarum/nicknames" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-nicknames-0821e5c982dd16d26c5260879b866eb416e8bb86";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/nicknames/zipball/0821e5c982dd16d26c5260879b866eb416e8bb86";
          sha256 = "1s30mwng73bp5pg0k0m036jisq2q6zwhmjn8h70hfmyf78kk8vwd";
        };
      };
    };
    "flarum/pusher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-pusher-5eccb38e045575c148fb5bbd26cc36cf86d58c5c";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/pusher/zipball/5eccb38e045575c148fb5bbd26cc36cf86d58c5c";
          sha256 = "1gfjm3ah5y696hcddmp9ffrj5pggcvzgzpsgrsgczdmnraz85j4l";
        };
      };
    };
    "flarum/statistics" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-statistics-51279d0d0d95672017db8cf7a355b0510f1a955d";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/statistics/zipball/51279d0d0d95672017db8cf7a355b0510f1a955d";
          sha256 = "1v94apg3fn0b8fjbk5vmkp9rik1x28rnn9pwg0cqbkmy7hfvm5mi";
        };
      };
    };
    "flarum/sticky" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-sticky-675900b9f1bc5004432880062d6ce3116c12c4c2";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/sticky/zipball/675900b9f1bc5004432880062d6ce3116c12c4c2";
          sha256 = "1j5xgprf2fg2rlshqvp1rkzbmlqf9p7dqi7c65mjhq60ifnw7bpy";
        };
      };
    };
    "flarum/subscriptions" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-subscriptions-532b7e61a387481055a0c9d5d07f78cd3d4e9bd7";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/subscriptions/zipball/532b7e61a387481055a0c9d5d07f78cd3d4e9bd7";
          sha256 = "0vr00xsk1kmn4p8rc3vlcskwj9d0ysqbfxkp6mf8986bkkznnaq3";
        };
      };
    };
    "flarum/suspend" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-suspend-409010635ce7d274cbe6eee661f75ed9b67b2cb0";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/suspend/zipball/409010635ce7d274cbe6eee661f75ed9b67b2cb0";
          sha256 = "1hyn8xl9x1xaifwhx6r5y3vy2qkdd0qnvpnjsdfa8v02skbagqpf";
        };
      };
    };
    "flarum/tags" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "flarum-tags-45cfb339e1ebd9f0204070f7f271c00282d20694";
        src = fetchurl {
          url = "https://api.github.com/repos/flarum/tags/zipball/45cfb339e1ebd9f0204070f7f271c00282d20694";
          sha256 = "13mr09bz5l9nzx317cm8j6dxiwz4j6xyr3ky382hrcw9ifd9yj6d";
        };
      };
    };
    "franzl/whoops-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "franzl-whoops-middleware-71d75c5fff75587d6194a051d510a9eca0e3a047";
        src = fetchurl {
          url = "https://api.github.com/repos/franzliedke/whoops-middleware/zipball/71d75c5fff75587d6194a051d510a9eca0e3a047";
          sha256 = "0c1h3rw1vv13vwgkpfr3bqqzxym8xb5mz9bmp4x7frw9gy64pla4";
        };
      };
    };
    "guzzlehttp/guzzle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-guzzle-fb7566caccf22d74d1ab270de3551f72a58399f5";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/guzzle/zipball/fb7566caccf22d74d1ab270de3551f72a58399f5";
          sha256 = "0cmpq50s5xi9sg1dygllrhwj5dz5bxxj83xkvjspz63751xr51cs";
        };
      };
    };
    "guzzlehttp/promises" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-promises-3a494dc7dc1d7d12e511890177ae2d0e6c107da6";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/promises/zipball/3a494dc7dc1d7d12e511890177ae2d0e6c107da6";
          sha256 = "1x8m4j1snrwyaywa0bsch26lr4050cnwpximbx4k66awc562f068";
        };
      };
    };
    "guzzlehttp/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-psr7-b635f279edd83fc275f822a1188157ffea568ff6";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/psr7/zipball/b635f279edd83fc275f822a1188157ffea568ff6";
          sha256 = "0734h3r8db06hcffagr8s7bxhjkvlfzvqg1klwmqidflwdwk7yj1";
        };
      };
    };
    "illuminate/bus" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-bus-d2a8ae4bfd881086e55455e470776358eab27eae";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/bus/zipball/d2a8ae4bfd881086e55455e470776358eab27eae";
          sha256 = "01d3fwlkdq93s8m9navrjy4anh24pgqjshbglnasc0hm9cqb2bxv";
        };
      };
    };
    "illuminate/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-cache-7ae5b3661413dad7264b5c69037190d766bae50f";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/cache/zipball/7ae5b3661413dad7264b5c69037190d766bae50f";
          sha256 = "101rlkv9dwlyhs1zgvb8dgap9avyz1yk4fpgfsi8g6r55w0xqmp3";
        };
      };
    };
    "illuminate/collections" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-collections-705a4e1ef93cd492c45b9b3e7911cccc990a07f4";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/collections/zipball/705a4e1ef93cd492c45b9b3e7911cccc990a07f4";
          sha256 = "180yqb0dk9zd6r7lmjj37722n17gdzxnsw1xdd24hw0lpdwm8n0q";
        };
      };
    };
    "illuminate/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-config-feac56ab7a5c70cf2dc60dffe4323eb9851f51a8";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/config/zipball/feac56ab7a5c70cf2dc60dffe4323eb9851f51a8";
          sha256 = "0yj7pfy7pfmhfx488cmn6qpdm60z2w93j4wvmgc2fip5nikhbqb1";
        };
      };
    };
    "illuminate/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-console-4aaa93223eb3bd8119157c95f58c022967826035";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/console/zipball/4aaa93223eb3bd8119157c95f58c022967826035";
          sha256 = "0bmxz9r4jbvw59w0rjcxjvrg6fwdwj60rywxj58dghjvckgrna7z";
        };
      };
    };
    "illuminate/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-container-14062628d05f75047c5a1360b9350028427d568e";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/container/zipball/14062628d05f75047c5a1360b9350028427d568e";
          sha256 = "1drpp736hv9mcib7varlnz31ykj6l1p45cviy42a5ramh63zgkif";
        };
      };
    };
    "illuminate/contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-contracts-5e0fd287a1b22a6b346a9f7cd484d8cf0234585d";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/contracts/zipball/5e0fd287a1b22a6b346a9f7cd484d8cf0234585d";
          sha256 = "0adggas9kvakrf5gy63agvnnjkgq8xwfjb32x89cqc7q6mhsw0f7";
        };
      };
    };
    "illuminate/database" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-database-1a5b0e4e6913415464fa2aab554a38b9e6fa44b1";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/database/zipball/1a5b0e4e6913415464fa2aab554a38b9e6fa44b1";
          sha256 = "0bkhndci45r2jv7hxr8b95vrx6sw0hps43bp4m2r12c7kxanm0x6";
        };
      };
    };
    "illuminate/events" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-events-b7f06cafb6c09581617f2ca05d69e9b159e5a35d";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/events/zipball/b7f06cafb6c09581617f2ca05d69e9b159e5a35d";
          sha256 = "083md4zmmjhls1cmwfjml3s3bq20h7amjah8vmfb3d261fn310w1";
        };
      };
    };
    "illuminate/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-filesystem-73db3e9a233ed587ba54f52ab8580f3c7bc872b2";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/filesystem/zipball/73db3e9a233ed587ba54f52ab8580f3c7bc872b2";
          sha256 = "1hdhgs212imbdgk7bzi1i7qmfgj81v771g1yyk153v5dkdm5fxg7";
        };
      };
    };
    "illuminate/hashing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-hashing-2617f4de8d0150a3f8641b086fafac8c1e0cdbf2";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/hashing/zipball/2617f4de8d0150a3f8641b086fafac8c1e0cdbf2";
          sha256 = "1h40sqdr6f98a59x1i94kqrq8a6jz1vn2v9h11xmjxwgfgszllkz";
        };
      };
    };
    "illuminate/macroable" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-macroable-aed81891a6e046fdee72edd497f822190f61c162";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/macroable/zipball/aed81891a6e046fdee72edd497f822190f61c162";
          sha256 = "0cf0532vxv4pgaqx6k9zk6d4r6xy43wbhrhblkhyr8pb354vj0gg";
        };
      };
    };
    "illuminate/mail" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-mail-557c01a4c6d3862829b004f198c1777a7f8fc35f";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/mail/zipball/557c01a4c6d3862829b004f198c1777a7f8fc35f";
          sha256 = "12sl1g2nbb9q2awhmiwcasdbq7q6nqz19jrjn132r6b3jjb887yi";
        };
      };
    };
    "illuminate/pipeline" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-pipeline-23aeff5b26ae4aee3f370835c76bd0f4e93f71d2";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/pipeline/zipball/23aeff5b26ae4aee3f370835c76bd0f4e93f71d2";
          sha256 = "0hfviaxxw4jrya1gf57camvx463hk4h1cmr0h56d0wg4jbnssjhw";
        };
      };
    };
    "illuminate/queue" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-queue-0023daabf67743f7a2bd8328ca2b5537d93e4ae7";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/queue/zipball/0023daabf67743f7a2bd8328ca2b5537d93e4ae7";
          sha256 = "1kxb5q5s6b46xaw5pvknv2bsmn9pkz6jy5jgnbck07snpgnyl250";
        };
      };
    };
    "illuminate/session" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-session-9c9988d7229d888c098eebbbb9fcb8c68580411c";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/session/zipball/9c9988d7229d888c098eebbbb9fcb8c68580411c";
          sha256 = "185lchbx5bxshspcg5d4b9xraqdqzsjxyzhkzyncg8zd5mn4pfwq";
        };
      };
    };
    "illuminate/support" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-support-1c79242468d3bbd9a0f7477df34f9647dde2a09b";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/support/zipball/1c79242468d3bbd9a0f7477df34f9647dde2a09b";
          sha256 = "1nhqbi7ymlmsxgd8q1hplgvmw5g7xkxy48rwdbshz6iww4bphj2v";
        };
      };
    };
    "illuminate/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-translation-e119d1e55351bd846579c333dd24f9a042b724b2";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/translation/zipball/e119d1e55351bd846579c333dd24f9a042b724b2";
          sha256 = "0ikm258fivln6si5zk3glm2mq13qrxzcl7j97wjf5car81f0jmni";
        };
      };
    };
    "illuminate/validation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-validation-bb104f15545a55664755f58a278c7013f835918a";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/validation/zipball/bb104f15545a55664755f58a278c7013f835918a";
          sha256 = "0c1dhip2yw4bqm0zhq3yj4l3gsh1qnshwp099bjb9wh58p3as8h9";
        };
      };
    };
    "illuminate/view" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-view-5e73eef48d9242532f81fadc14c816a01bfb1388";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/view/zipball/5e73eef48d9242532f81fadc14c816a01bfb1388";
          sha256 = "03phq5vdaj4rxj87mc3q9i59zsiiisyylcnkh14ih5a6nsczy368";
        };
      };
    };
    "intervention/image" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "intervention-image-04be355f8d6734c826045d02a1079ad658322dad";
        src = fetchurl {
          url = "https://api.github.com/repos/Intervention/image/zipball/04be355f8d6734c826045d02a1079ad658322dad";
          sha256 = "1cbg43hm2jgwb7gm1r9xcr4cpx8ng1zr93zx6shk9xhjlssnv0bx";
        };
      };
    };
    "jaybizzle/crawler-detect" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jaybizzle-crawler-detect-4531e4a70d55d10cbe7d41ac1ff0d75a5fe2ef1e";
        src = fetchurl {
          url = "https://api.github.com/repos/JayBizzle/Crawler-Detect/zipball/4531e4a70d55d10cbe7d41ac1ff0d75a5fe2ef1e";
          sha256 = "0f4g6kbz6ypg3jyfnqw2l1gk40xgxwnvyrrz719f3qxh3bh5k9iy";
        };
      };
    };
    "jenssegers/agent" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jenssegers-agent-daa11c43729510b3700bc34d414664966b03bffe";
        src = fetchurl {
          url = "https://api.github.com/repos/jenssegers/agent/zipball/daa11c43729510b3700bc34d414664966b03bffe";
          sha256 = "0f0wy69w9mdsajfgriwlnpqhqxp83q44p6ggcd6h1bi8ri3h0897";
        };
      };
    };
    "laminas/laminas-diactoros" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laminas-laminas-diactoros-9f3f4bf5b99c9538b6f1dbcc20f6fec357914f9e";
        src = fetchurl {
          url = "https://api.github.com/repos/laminas/laminas-diactoros/zipball/9f3f4bf5b99c9538b6f1dbcc20f6fec357914f9e";
          sha256 = "04jp4xnlfv10h6wga9gyj722s10p6a8hh4qwq20nc4bwhafcidaw";
        };
      };
    };
    "laminas/laminas-escaper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laminas-laminas-escaper-ee7a4c37bf3d0e8c03635d5bddb5bb3184ead490";
        src = fetchurl {
          url = "https://api.github.com/repos/laminas/laminas-escaper/zipball/ee7a4c37bf3d0e8c03635d5bddb5bb3184ead490";
          sha256 = "0hqxa983ams18crmb2zix6h12ivv8574r37jflk9dzhjyqz7zax5";
        };
      };
    };
    "laminas/laminas-httphandlerrunner" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laminas-laminas-httphandlerrunner-a894a341ec2b0995919265db4f463fb1d5128134";
        src = fetchurl {
          url = "https://api.github.com/repos/laminas/laminas-httphandlerrunner/zipball/a894a341ec2b0995919265db4f463fb1d5128134";
          sha256 = "0kkavhbqvsk8n8bbp5fv3pkwg0q2cq84apzsifhqc4rq2apz6h1y";
        };
      };
    };
    "laminas/laminas-stratigility" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laminas-laminas-stratigility-d45eec2f61b9706d9efcb398af53a196c3c7f301";
        src = fetchurl {
          url = "https://api.github.com/repos/laminas/laminas-stratigility/zipball/d45eec2f61b9706d9efcb398af53a196c3c7f301";
          sha256 = "1kmb8xb2nwlbv63511mqz47jqisdn6apai59h7919f0l611ii8y4";
        };
      };
    };
    "laravel/serializable-closure" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-serializable-closure-f23fe9d4e95255dacee1bf3525e0810d1a1b0f37";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/serializable-closure/zipball/f23fe9d4e95255dacee1bf3525e0810d1a1b0f37";
          sha256 = "0dyvqph5q1lb6gl6ga4b1xkziqzj6s2ia5pbd7h40anm4sh3z8dl";
        };
      };
    };
    "league/commonmark" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-commonmark-d44a24690f16b8c1808bf13b1bd54ae4c63ea048";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/commonmark/zipball/d44a24690f16b8c1808bf13b1bd54ae4c63ea048";
          sha256 = "1qx99m1qa2g3l6r2fim3rak6qh28zjj8sqjj86nq743dm3yszygw";
        };
      };
    };
    "league/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-config-754b3604fb2984c71f4af4a9cbe7b57f346ec1f3";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/config/zipball/754b3604fb2984c71f4af4a9cbe7b57f346ec1f3";
          sha256 = "0yjb85cd0qa0mra995863dij2hmcwk9x124vs8lrwiylb0l3mn8s";
        };
      };
    };
    "league/flysystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-flysystem-3239285c825c152bcc315fe0e87d6b55f5972ed1";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/flysystem/zipball/3239285c825c152bcc315fe0e87d6b55f5972ed1";
          sha256 = "0p1cirl7j9b3gvbp264d08abfnrki89jr7rx0cbw0bjw1apf4spz";
        };
      };
    };
    "league/mime-type-detection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-mime-type-detection-ff6248ea87a9f116e78edd6002e39e5128a0d4dd";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/mime-type-detection/zipball/ff6248ea87a9f116e78edd6002e39e5128a0d4dd";
          sha256 = "1a63nvqd6cz3vck3y8vjswn6c3cfwh13p0cn0ci5pqdf0bgjvvfz";
        };
      };
    };
    "matthiasmullie/minify" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "matthiasmullie-minify-ae42a47d7fecc1fbb7277b2f2d84c37a33edc3b1";
        src = fetchurl {
          url = "https://api.github.com/repos/matthiasmullie/minify/zipball/ae42a47d7fecc1fbb7277b2f2d84c37a33edc3b1";
          sha256 = "1sm5nb0v6j9dsbip32lmpz4q6mnkcwf87947ca9j9gpnq0p2j2gn";
        };
      };
    };
    "matthiasmullie/path-converter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "matthiasmullie-path-converter-e7d13b2c7e2f2268e1424aaed02085518afa02d9";
        src = fetchurl {
          url = "https://api.github.com/repos/matthiasmullie/path-converter/zipball/e7d13b2c7e2f2268e1424aaed02085518afa02d9";
          sha256 = "0b42v65bwds4h9y8dgqxafvkxpwjqa7y236sfknd0jbhjdr1hj3r";
        };
      };
    };
    "middlewares/base-path" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "middlewares-base-path-9540b7b3aea29f22be269ad4c182455e70e38b4a";
        src = fetchurl {
          url = "https://api.github.com/repos/middlewares/base-path/zipball/9540b7b3aea29f22be269ad4c182455e70e38b4a";
          sha256 = "107c82sxv0pm4gys58xij5lbc1046ll5hc53bgfh4zyhwlgfdfr7";
        };
      };
    };
    "middlewares/base-path-router" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "middlewares-base-path-router-36e3860cfd917ad51d10e238f82796c8b2504908";
        src = fetchurl {
          url = "https://api.github.com/repos/middlewares/base-path-router/zipball/36e3860cfd917ad51d10e238f82796c8b2504908";
          sha256 = "0l8sy2mvbgbqsxrs99xk2nyxpj8jg1qw9xamy409i0ndqbplr33i";
        };
      };
    };
    "middlewares/request-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "middlewares-request-handler-f07840434347520c11959caa54ab3476e16ceee2";
        src = fetchurl {
          url = "https://api.github.com/repos/middlewares/request-handler/zipball/f07840434347520c11959caa54ab3476e16ceee2";
          sha256 = "0crv2jnx0g5cg18nbb1rl8xjf1hn7qnjb44vvjvk0qjp3p5smdhl";
        };
      };
    };
    "middlewares/utils" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "middlewares-utils-670b135ce0dbd040eadb025a9388f9bd617cc010";
        src = fetchurl {
          url = "https://api.github.com/repos/middlewares/utils/zipball/670b135ce0dbd040eadb025a9388f9bd617cc010";
          sha256 = "0mkhry8fd07jsa3wnyf0hrf8h38j5z7x0zyamncm1k7a32fccxwp";
        };
      };
    };
    "mobiledetect/mobiledetectlib" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "mobiledetect-mobiledetectlib-fc9cccd4d3706d5a7537b562b59cc18f9e4c0cb1";
        src = fetchurl {
          url = "https://api.github.com/repos/serbanghita/Mobile-Detect/zipball/fc9cccd4d3706d5a7537b562b59cc18f9e4c0cb1";
          sha256 = "1qmkrbdrfnxgd7lcgw7g30r8qc6yg1c9lkdam54zhgxhcc2ryxqs";
        };
      };
    };
    "monolog/monolog" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "monolog-monolog-904713c5929655dc9b97288b69cfeedad610c9a1";
        src = fetchurl {
          url = "https://api.github.com/repos/Seldaek/monolog/zipball/904713c5929655dc9b97288b69cfeedad610c9a1";
          sha256 = "17fjd5dk45b6dbfx15vxqk6mnm3fsn2kd8nsjfjd2zk3zfihq4jj";
        };
      };
    };
    "nesbot/carbon" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nesbot-carbon-4f991ed2a403c85efbc4f23eb4030063fdbe01da";
        src = fetchurl {
          url = "https://api.github.com/repos/briannesbitt/Carbon/zipball/4f991ed2a403c85efbc4f23eb4030063fdbe01da";
          sha256 = "09k9ljqwn6qsr5z7wp2yv8p0vqr4hn03lyxvm76xm2g6wb6l43gp";
        };
      };
    };
    "nette/schema" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nette-schema-abbdbb70e0245d5f3bf77874cea1dfb0c930d06f";
        src = fetchurl {
          url = "https://api.github.com/repos/nette/schema/zipball/abbdbb70e0245d5f3bf77874cea1dfb0c930d06f";
          sha256 = "16i8gim0jpmmbq0pp4faw8kn2448yvpgsd1zvipbv9xrk37vah5q";
        };
      };
    };
    "nette/utils" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nette-utils-cacdbf5a91a657ede665c541eda28941d4b09c1e";
        src = fetchurl {
          url = "https://api.github.com/repos/nette/utils/zipball/cacdbf5a91a657ede665c541eda28941d4b09c1e";
          sha256 = "0v3as5xdmr9j7d4q4ly18f7g8g0sjcy25l4ispsdp60byldi7m8h";
        };
      };
    };
    "nikic/fast-route" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-fast-route-31fa86924556b80735f98b294a7ffdfb26789f22";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/FastRoute/zipball/31fa86924556b80735f98b294a7ffdfb26789f22";
          sha256 = "0wd29sbh0b9irn2y1qy511w5lc0qcz3r0npas02wmbxbxyv52m5k";
        };
      };
    };
    "opis/closure" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "opis-closure-3d81e4309d2a927abbe66df935f4bb60082805ad";
        src = fetchurl {
          url = "https://api.github.com/repos/opis/closure/zipball/3d81e4309d2a927abbe66df935f4bb60082805ad";
          sha256 = "0hqs6rdkkcggswrgjlispkby2yg4hwn63bl2ma62lnmpfbpwn0sd";
        };
      };
    };
    "psr/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-container-513e0666f7216c7459170d56df27dfcefe1689ea";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/container/zipball/513e0666f7216c7459170d56df27dfcefe1689ea";
          sha256 = "00yvj3b5ls2l1d0sk38g065raw837rw65dx1sicggjnkr85vmfzz";
        };
      };
    };
    "psr/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-event-dispatcher-dbefd12671e8a14ec7f180cab83036ed26714bb0";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/event-dispatcher/zipball/dbefd12671e8a14ec7f180cab83036ed26714bb0";
          sha256 = "05nicsd9lwl467bsv4sn44fjnnvqvzj1xqw2mmz9bac9zm66fsjd";
        };
      };
    };
    "psr/http-client" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-client-0955afe48220520692d2d09f7ab7e0f93ffd6a31";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-client/zipball/0955afe48220520692d2d09f7ab7e0f93ffd6a31";
          sha256 = "09r970lfpwil861gzm47446ck1s6km6ijibkxl13p1ymwdchnv6m";
        };
      };
    };
    "psr/http-factory" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-factory-e616d01114759c4c489f93b099585439f795fe35";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-factory/zipball/e616d01114759c4c489f93b099585439f795fe35";
          sha256 = "1vzimn3h01lfz0jx0lh3cy9whr3kdh103m1fw07qric4pnnz5kx8";
        };
      };
    };
    "psr/http-message" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-message-cb6ce4845ce34a8ad9e68117c10ee90a29919eba";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-message/zipball/cb6ce4845ce34a8ad9e68117c10ee90a29919eba";
          sha256 = "1s87sajxsxl30ciqyhx0vir2pai63va4ssbnq7ki6s050i4vm80h";
        };
      };
    };
    "psr/http-server-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-server-handler-84c4fb66179be4caaf8e97bd239203245302e7d4";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-server-handler/zipball/84c4fb66179be4caaf8e97bd239203245302e7d4";
          sha256 = "0cda811xcry8l1qdfr7ykgv8by7qlkq6p4wl99mzc0saish5pq5l";
        };
      };
    };
    "psr/http-server-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-server-middleware-c1481f747daaa6a0782775cd6a8c26a1bf4a3829";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-server-middleware/zipball/c1481f747daaa6a0782775cd6a8c26a1bf4a3829";
          sha256 = "10kvhz32j92byg2fdqsckl18pkr5w4kzwxgiz13fpc8ry8q4mhjb";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-d49695b909c3b7628b6289db5479a1c204601f11";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/log/zipball/d49695b909c3b7628b6289db5479a1c204601f11";
          sha256 = "0sb0mq30dvmzdgsnqvw3xh4fb4bqjncx72kf8n622f94dd48amln";
        };
      };
    };
    "psr/simple-cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-simple-cache-408d5eafb83c57f6365a3ca330ff23aa4a5fa39b";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/simple-cache/zipball/408d5eafb83c57f6365a3ca330ff23aa4a5fa39b";
          sha256 = "1djgzclkamjxi9jy4m9ggfzgq1vqxaga2ip7l3cj88p7rwkzjxgw";
        };
      };
    };
    "pusher/pusher-php-server" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "pusher-pusher-php-server-2cf2ba85e7ce3250468a1c42ab7c948a7d43839d";
        src = fetchurl {
          url = "https://api.github.com/repos/pusher/pusher-http-php/zipball/2cf2ba85e7ce3250468a1c42ab7c948a7d43839d";
          sha256 = "16bk4yfmbzqd8z61vk6chk67kkva8s5dgn33xhyvqjk1i3w9frik";
        };
      };
    };
    "ralouphie/getallheaders" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ralouphie-getallheaders-120b605dfeb996808c31b6477290a714d356e822";
        src = fetchurl {
          url = "https://api.github.com/repos/ralouphie/getallheaders/zipball/120b605dfeb996808c31b6477290a714d356e822";
          sha256 = "1bv7ndkkankrqlr2b4kw7qp3fl0dxi6bp26bnim6dnlhavd6a0gg";
        };
      };
    };
    "ramsey/collection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-collection-a4b48764bfbb8f3a6a4d1aeb1a35bb5e9ecac4a5";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/collection/zipball/a4b48764bfbb8f3a6a4d1aeb1a35bb5e9ecac4a5";
          sha256 = "0y5s9rbs023sw94yzvxr8fn9rr7xw03f08zmc9n9jl49zlr5s52p";
        };
      };
    };
    "ramsey/uuid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-uuid-60a4c63ab724854332900504274f6150ff26d286";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/uuid/zipball/60a4c63ab724854332900504274f6150ff26d286";
          sha256 = "1w1i50pbd18awmvzqjkbszw79dl09912ibn95qm8lxr4nsjvbb27";
        };
      };
    };
    "s9e/regexp-builder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "s9e-regexp-builder-3a646bc7c40dba41903b7065f32230721e00df3a";
        src = fetchurl {
          url = "https://api.github.com/repos/s9e/RegexpBuilder/zipball/3a646bc7c40dba41903b7065f32230721e00df3a";
          sha256 = "0y25vpdp1pnmyxglzvrynzsz6g92x74pssjanwygmqqn2cdyicf5";
        };
      };
    };
    "s9e/sweetdom" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "s9e-sweetdom-dd5d814f93621b1489bfbac8e0331122b928a18a";
        src = fetchurl {
          url = "https://api.github.com/repos/s9e/SweetDOM/zipball/dd5d814f93621b1489bfbac8e0331122b928a18a";
          sha256 = "1ph28byjgkz8qd4hrdrcb6dgz7kicfwfkmz0pqv97jdxyjb05cxn";
        };
      };
    };
    "s9e/text-formatter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "s9e-text-formatter-48a2f3a3fb18af8d78330204732a3369441c4060";
        src = fetchurl {
          url = "https://api.github.com/repos/s9e/TextFormatter/zipball/48a2f3a3fb18af8d78330204732a3369441c4060";
          sha256 = "1kfy7pcx4wbfa9g73npjvz3b9awj1rbilq2j9s1r305iaxpsjjc8";
        };
      };
    };
    "staudenmeir/eloquent-eager-limit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "staudenmeir-eloquent-eager-limit-439135c4b3361a313c2e7102d68bf807518d1bf9";
        src = fetchurl {
          url = "https://api.github.com/repos/staudenmeir/eloquent-eager-limit/zipball/439135c4b3361a313c2e7102d68bf807518d1bf9";
          sha256 = "0jpb3pbq3sqscypj9cdpi6rd6jv2d42zy0kz17jzkpnibwcw6s9b";
        };
      };
    };
    "swiftmailer/swiftmailer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "swiftmailer-swiftmailer-8a5d5072dca8f48460fce2f4131fcc495eec654c";
        src = fetchurl {
          url = "https://api.github.com/repos/swiftmailer/swiftmailer/zipball/8a5d5072dca8f48460fce2f4131fcc495eec654c";
          sha256 = "1p9m4fw9y9md9a7msbmnc0hpdrky8dwrllnyg1qf1cdyp9d70x1d";
        };
      };
    };
    "sycho/codecs-base64vlq" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sycho-codecs-base64vlq-210932edfb29049831e4def7f11a264944132ac9";
        src = fetchurl {
          url = "https://api.github.com/repos/SychO9/codecs-base64vlq/zipball/210932edfb29049831e4def7f11a264944132ac9";
          sha256 = "0p7zj32s5ak85dq5dzx18ssbhih32nj6jbavkzghz7l0lnpfir62";
        };
      };
    };
    "sycho/errors" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sycho-errors-82e955d247940aa7feed35e1ec7a61fc46639582";
        src = fetchurl {
          url = "https://api.github.com/repos/SychO9/errors/zipball/82e955d247940aa7feed35e1ec7a61fc46639582";
          sha256 = "1z1xn0kf6w8djpa2rh4pwz11lrlkc5x97ggczskh4w1kk96h653m";
        };
      };
    };
    "sycho/json-api" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sycho-json-api-5ef867317a6b39b307af0fc98c5b9c5828607301";
        src = fetchurl {
          url = "https://api.github.com/repos/SychO9/json-api-php/zipball/5ef867317a6b39b307af0fc98c5b9c5828607301";
          sha256 = "0cbw95g94ip5h554z5h8iz8jyswgd4wicj6d2r28bhw0sq23kyjx";
        };
      };
    };
    "sycho/sourcemap" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sycho-sourcemap-81d514186e37efbea7f4dd701ea9133fd3412bf1";
        src = fetchurl {
          url = "https://api.github.com/repos/SychO9/sourcemap/zipball/81d514186e37efbea7f4dd701ea9133fd3412bf1";
          sha256 = "0wfnw14zmjqaf6723lxzf7nqzr3nvif5xz8535w5b3bhk95z1p48";
        };
      };
    };
    "symfony/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-config-2a6b1111d038adfa15d52c0871e540f3b352d1e4";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/config/zipball/2a6b1111d038adfa15d52c0871e540f3b352d1e4";
          sha256 = "1bf5r6g6ab2ncg3hrri1vwklwlqnhccvbyfhyjn43vi8c0cxqlfw";
        };
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-560fc3ed7a43e6d30ea94a07d77f9a60b8ed0fb8";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/console/zipball/560fc3ed7a43e6d30ea94a07d77f9a60b8ed0fb8";
          sha256 = "1ir8wsdkd11a3v00pbxg9s5rxd9418f17ic4rf6v69ivl1b3mhm9";
        };
      };
    };
    "symfony/css-selector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-css-selector-88453e64cd86c5b60e8d2fb2c6f953bbc353ffbf";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/css-selector/zipball/88453e64cd86c5b60e8d2fb2c6f953bbc353ffbf";
          sha256 = "18lvkwbc418fhb5s383ggiawg3a7bi610i8svf3vg5yfkvr9yw3r";
        };
      };
    };
    "symfony/deprecation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-deprecation-contracts-7c3aff79d10325257a001fcf92d991f24fc967cf";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/deprecation-contracts/zipball/7c3aff79d10325257a001fcf92d991f24fc967cf";
          sha256 = "0p0c2942wjq1bb06y9i8gw6qqj7sin5v5xwsvl0zdgspbr7jk1m9";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-1df20e45d56da29a4b1d8259dd6e950acbf1b13f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher/zipball/1df20e45d56da29a4b1d8259dd6e950acbf1b13f";
          sha256 = "162ncixk5yfqjn6rzmiqri2ycj34lr2w2lwgqgra99ij2p2gk3bn";
        };
      };
    };
    "symfony/event-dispatcher-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-contracts-a76aed96a42d2b521153fb382d418e30d18b59df";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher-contracts/zipball/a76aed96a42d2b521153fb382d418e30d18b59df";
          sha256 = "1w49s1q6xhcmkgd3xkyjggiwys0wvyny0p3018anvdi0k86zg678";
        };
      };
    };
    "symfony/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-filesystem-edd36776956f2a6fcf577edb5b05eb0e3bdc52ae";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/filesystem/zipball/edd36776956f2a6fcf577edb5b05eb0e3bdc52ae";
          sha256 = "1idya1y7m51bgk7h3c4s9v02lq2zf35krpy08ypn103x29ghhypa";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-078e9a5e1871fcfe6a5ce421b539344c21afef19";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/finder/zipball/078e9a5e1871fcfe6a5ce421b539344c21afef19";
          sha256 = "0w14pizksi8yqjzdgghxbrvly3svx5diyi23dli7kqhjf6q3g6a9";
        };
      };
    };
    "symfony/http-foundation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-foundation-f66be2706075c5f6325d2fe2b743a57fb5d23f6b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-foundation/zipball/f66be2706075c5f6325d2fe2b743a57fb5d23f6b";
          sha256 = "09w81aya6jz9wm7xnax2ys4wd2hxjrixr0rnn2khnyggd2njj2mq";
        };
      };
    };
    "symfony/mime" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-mime-ae0a1032a450a3abf305ee44fc55ed423fbf16e3";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/mime/zipball/ae0a1032a450a3abf305ee44fc55ed423fbf16e3";
          sha256 = "1fj0z9bxwvw5w7h218n885xk2avsyangq9xvqajx1vjighycliga";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-5bbc823adecdae860bb64756d639ecfec17b050a";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-ctype/zipball/5bbc823adecdae860bb64756d639ecfec17b050a";
          sha256 = "0vyv70z1yi2is727d1mkb961w5r1pb1v3wy1pvdp30h8ffy15wk6";
        };
      };
    };
    "symfony/polyfill-iconv" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-iconv-927013f3aac555983a5059aada98e1907d842695";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-iconv/zipball/927013f3aac555983a5059aada98e1907d842695";
          sha256 = "1qmnzd3r2l35rx84r8ai0596dywsj7q5y3dngaf1vsz16k5ig409";
        };
      };
    };
    "symfony/polyfill-intl-grapheme" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-grapheme-511a08c03c1960e08a883f4cffcacd219b758354";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-grapheme/zipball/511a08c03c1960e08a883f4cffcacd219b758354";
          sha256 = "0ifsgsyxf0z0nkynqvr5259dm5dsmbgdpvyi5zfvy8935mi0ki0i";
        };
      };
    };
    "symfony/polyfill-intl-idn" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-idn-639084e360537a19f9ee352433b84ce831f3d2da";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-idn/zipball/639084e360537a19f9ee352433b84ce831f3d2da";
          sha256 = "1i2wcsbfbwdyrx8545yrrvbdaf4l2393pjvg9266q74611j6pzxj";
        };
      };
    };
    "symfony/polyfill-intl-messageformatter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-messageformatter-861fe322b162bc23822a1ee0bd62d5c7eef8c6c7";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-messageformatter/zipball/861fe322b162bc23822a1ee0bd62d5c7eef8c6c7";
          sha256 = "0w5rzsg8gc7bzd8m0yvllqgz41l23dxsvxpqz2r39jfrk82qrkjr";
        };
      };
    };
    "symfony/polyfill-intl-normalizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-normalizer-19bd1e4fcd5b91116f14d8533c57831ed00571b6";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-normalizer/zipball/19bd1e4fcd5b91116f14d8533c57831ed00571b6";
          sha256 = "1d80jph5ykiw6ydv8fwd43s0aglh24qc1yrzds2f3aqanpbk1gr2";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-8ad114f6b39e2c98a8b0e3bd907732c207c2b534";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/8ad114f6b39e2c98a8b0e3bd907732c207c2b534";
          sha256 = "1ym84qp609i50lv4vkd4yz99y19kaxd5kmpdnh66mxx1a4a104mi";
        };
      };
    };
    "symfony/polyfill-php72" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php72-869329b1e9894268a8a61dabb69153029b7a8c97";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php72/zipball/869329b1e9894268a8a61dabb69153029b7a8c97";
          sha256 = "1h0lbh8d41sa4fymmw03yzws3v3z0lz4lv1kgcld7r53i2m3wfwp";
        };
      };
    };
    "symfony/polyfill-php73" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php73-9e8ecb5f92152187c4799efd3c96b78ccab18ff9";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php73/zipball/9e8ecb5f92152187c4799efd3c96b78ccab18ff9";
          sha256 = "1p0jr92x323pl4frjbhmziyk5g1zig1g30i1v1p0wfli2sq8h5mb";
        };
      };
    };
    "symfony/polyfill-php80" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php80-7a6ff3f1959bb01aefccb463a0f2cd3d3d2fd936";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php80/zipball/7a6ff3f1959bb01aefccb463a0f2cd3d3d2fd936";
          sha256 = "16yydk7rsknlasrpn47n4b4js8svvp4rxzw99dkav52wr3cqmcwd";
        };
      };
    };
    "symfony/polyfill-php81" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php81-707403074c8ea6e2edaf8794b0157a0bfa52157a";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php81/zipball/707403074c8ea6e2edaf8794b0157a0bfa52157a";
          sha256 = "05qrjfnnnz402l11wm0ydblrip7hjll12yqxmh2wd02b0s8dj29f";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-e3c46cc5689c8782944274bb30702106ecbe3b64";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/process/zipball/e3c46cc5689c8782944274bb30702106ecbe3b64";
          sha256 = "103bdd0nycl9k9lgf64p0f6qy12mf5k5anwdr2vhfy8ab4kv6a7y";
        };
      };
    };
    "symfony/service-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-service-contracts-4b426aac47d6427cc1a1d0f7e2ac724627f5966c";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/service-contracts/zipball/4b426aac47d6427cc1a1d0f7e2ac724627f5966c";
          sha256 = "0lh0vxy0h4wsjmnlf42s950bicsvkzz6brqikfnfb5kmvi0xhcm6";
        };
      };
    };
    "symfony/string" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-string-f2e190ee75ff0f5eced645ec0be5c66fac81f51f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/string/zipball/f2e190ee75ff0f5eced645ec0be5c66fac81f51f";
          sha256 = "1zbn32ra3zjl59iq7maascakxnh6h0rn3yqqfkp5rrn60xm9dn0j";
        };
      };
    };
    "symfony/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-de237e59c5833422342be67402d487fbf50334ff";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/translation/zipball/de237e59c5833422342be67402d487fbf50334ff";
          sha256 = "10qc1fymfvchk161hykkbqpy5ndxh6kigjhjsz5qp968dqcrckj2";
        };
      };
    };
    "symfony/translation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-contracts-136b19dd05cdf0709db6537d058bcab6dd6e2dbe";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/translation-contracts/zipball/136b19dd05cdf0709db6537d058bcab6dd6e2dbe";
          sha256 = "1z1514i3gsxdisyayzh880i8rj954qim7c183cld91kvvqcqi7x0";
        };
      };
    };
    "symfony/yaml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-yaml-4cd2e3ea301aadd76a4172756296fe552fb45b0b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/yaml/zipball/4cd2e3ea301aadd76a4172756296fe552fb45b0b";
          sha256 = "18yirwiqbh11fwlpqypm0wlc0lnx7prgk68xrn607zcg6cxnfhiz";
        };
      };
    };
    "tijsverkoyen/css-to-inline-styles" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tijsverkoyen-css-to-inline-styles-c42125b83a4fa63b187fdf29f9c93cb7733da30c";
        src = fetchurl {
          url = "https://api.github.com/repos/tijsverkoyen/CssToInlineStyles/zipball/c42125b83a4fa63b187fdf29f9c93cb7733da30c";
          sha256 = "0ckk04hwwz0fdkfr20i7xrhdjcnnw1b0liknbb81qyr1y4b7x3dd";
        };
      };
    };
    "voku/portable-ascii" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "voku-portable-ascii-87337c91b9dfacee02452244ee14ab3c43bc485a";
        src = fetchurl {
          url = "https://api.github.com/repos/voku/portable-ascii/zipball/87337c91b9dfacee02452244ee14ab3c43bc485a";
          sha256 = "1j2xpbv7xiwxwb6gfc3h6imc6xcbyb2jw3h8wgfnpvjl5yfbi4xb";
        };
      };
    };
    "webmozart/assert" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-assert-11cb2199493b2f8a3b53e7f19068fc6aac760991";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozarts/assert/zipball/11cb2199493b2f8a3b53e7f19068fc6aac760991";
          sha256 = "18qiza1ynwxpi6731jx1w5qsgw98prld1lgvfk54z92b1nc7psix";
        };
      };
    };
    "wikimedia/less.php" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "wikimedia-less.php-0d5b30ba792bdbf8991a646fc9c30561b38a5559";
        src = fetchurl {
          url = "https://api.github.com/repos/wikimedia/less.php/zipball/0d5b30ba792bdbf8991a646fc9c30561b38a5559";
          sha256 = "06f5z6g4pk6lvmakcsdwysyi6yknmvqk7p1krb0zra7hi41qwirr";
        };
      };
    };
  };
  devPackages = {};
in
composerEnv.buildPackage rec {
  inherit packages devPackages noDev;

  name = "flarum";
  version = "v1.8.0";
  src = fetchFromGitHub {
    owner = "flarum";
    repo = "flarum";
    rev = version;
    sha256 = "sha256-xadZIdyH20mxfxCyiDRtSRSrPj8DWXpuup61WSsjgWw=";
  }
  # src = composerEnv.filterSrc ./.;;
  src = ./src;
  executable = false;
  symlinkDependencies = false;
  meta = {
    homepage = "https://flarum.org/";
    license = "MIT";
  };
}
