package Email::MIME::MobileJP;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.07';


1;
__END__

=for stopwords softbank

=encoding utf8

=head1 NAME

Email::MIME::MobileJP - E-mail toolkit for Japanese Mobile Phones

=head1 DESCRIPTION

B<WARNING! THIS MODULE IS IN THE BETA QUALITY. API MAY CHANGE WITHOUT NOTICE!>

Email::MIME::MobileJP is all in one E-mail toolkit for Japanese mobile phones.

これは、Email::MIME シリーズ、および、mobile 関係のモジュールをとりまとめて、カジュアルにつかえるようにするためのモジュールです。

E-mail まわりの処理をやるためのノウハウをまとめておけば、後々、お気楽にできるはずということです。

=head1 クックブック

=head2 メールの受信(Parsing)

メールのパーズは、以下のように、メールの文字列をくわせてやればいいです。

    use Email::MIME::MobileJP::Parser;

    my $src_text = do { local $/; <> };
    my $mail = Email::MIME::MobileJP::Parser->new($src_text);

メールオブジェクトから Subject をえるには以下のようにしましょう。
ここでとれるものは MIME ヘッダにはいっている情報をもとに、UTF-8 に decode された文字列です。
可能ならば絵文字も decode します。これには L<Encode::JP::Mobile> を利用しています。

    my $subject = $mail->subject(); # サブジェクトをえる

From をえるには以下のようにします。各要素は L<Email::Address::Loose> のインスタンスです。

    my ($from) = $mail->from();

To も同様です。

    my ($to) = $mail->to();

=head3 text part をえる

text/plain な part をすべてえたい場合には以下のようにします。返り値は、UTF-8 decode された、文字列の配列です。

    my @texts = $mail->get_texts();

text/html なパートのみがほしい場合には以下のようにします。

    my @texts = $mail->get_texts(qr{^text/html});

=head3 画像 part をえる

以下のように、get_parts というメソッドであつめましょう。@images の各要素は、パートをあらわす Email::MIME のインスタンスです。

    my $mail = Email::MIME::MobileJP->new($src);
    my @images = $mail->get_parts(qr{^image/jpeg});;

=head3 SPFの確認

SPF で、本当にケータイからおくられてるかとかチェックできますが、softbank の SPF がくさってるって nekokak がいってたので、あんまり役にたたないかもしれない。@masason どうにかしてください。詳細は以下のサイトをみてください。

http://blog.nekokak.org/show?guid=Vl8eRFxp3xGW08LZob1Swg

=head2 メールの送信

=head3 メールオブジェクトを作成する

Email::MIME::MobileJP::Creator をつかえば、簡単にメールオブジェクトを作成できます。

    use utf8;
    use Email::MIME::MobileJP::Creator;
    use Email::Send;

    my $to = 'example@ezweb.ne.jp';
    my $creator = Email::MIME::MobileJP::Creator->new($to);
       $creator->body('元気でやってるかー?');
       $creator->from('from@example.com');
       $creator->subject('コンニチワ');
    my $mail = $creator->finalize();

    # Email::Send で送信する
    my $sender = Email::Send->new({mailer => 'Sendmail'});
    $sender->send($mail);

=head3 添付したい場合

マルチパートで写真などを添付したい場合には以下のようにすればよいでしょう。

    use utf8;
    use Email::MIME::MobileJP::Creator;

    my $to = 'example@ezweb.ne.jp';
    my $creator = Email::MIME::MobileJP::Creator->new($to);
       $creator->from('from@example.com');
       $creator->subject('コンニチワ');
       $creator->add_text_part('元気でやってるかー?');
       $creator->add_part(
            $photo => {
                    'fimename'     => 'hoge.jpg',
                    'content_type' => 'image/jpeg',
                    'encoding'     => 'base64',
                    'name'         => 'sample.jpg',
            },
       );
    my $mail = $creator->finalize;

    # Email::Send で送信する
    my $sender = Email::Send->new({mailer => 'Sendmail'});
    $sender->send($mail);

=head3 Email::MIME::MobileJP::Template のやつをつかうパターン

    my $mail_maker = Email::MIME::MobileJP::Template->new('Text::Xslate' => {path => ['email_tmpl/']});
    my $mail = $mail_maker->render('signup.eml', {token => $token, syntax => 'TTerse'});
    my $sender = Email::Send->new({mailer => 'Sendmail'});
    $sender->send($mail);

ただしここで email_tmpl/signup.eml の中身は、以下のとおり。

    Subject: [Example] サインアップ!

    以下をクリックせよ
    http://example.com/signup/[% token %]

こういうテンプレをおいておけば、簡単にメールを送信できるのでたいへんべんりですね。

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
