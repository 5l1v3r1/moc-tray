#!/usr/bin/perl
# simple script to instantly download currently played stream with streamripper

use strict;
use warnings;
use Gtk2 -init;
use Glib qw/TRUE FALSE/;
use MIME::Base64;
use Data::Dumper;
use Gtk2::Helper;
use FileHandle;

# rename 'mp3' to your desired download directory in ~
my $dl_dir = 'mp3';

my @info = get_info();
my $pid = 1;
my $tag;

my $in = FileHandle->new();
my $ico = decode_base64(
    'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QAAAAAAAD5Q7t/AAAACXB
IWXMAAA3WAAAN1gGQb3mcAAAEvUlEQVRIx5WVS4gcRRjH/1U13T3P3WRnJ/uIBqJkwRjQhGQVXZQcIoI
HCeQgOXtZNYqPkIuIJ085iFn1YjwEAwlGQRKIq6AY0INGYmISH0nc7Kzz2HWePd09U9Vd9XmY2WVfwlq
HroYu/r/v8e+vGNZZH5/6BG6zae/Zs2fIcRyLiAgAQN0HLTtrjEGxWKweOvisO5jLoVqprNBiq8XfPfE
BXnlpEpd/vvJ8oTB3tNFoCM75MsDiRgABIib4wMDgd3PF0hHf9/3XXn5xhV5sNWDr1tEemfZ+NT09Vql
UIQQHLYVNvXcCwBD4Pp7cvz/cvXdf5s6dO/5qvTUAIkK1cBdhFEJKBaUkGGNLost3xoD8XB5u04Vl2et
Vey1ASoVMug86KlGn04HrtsAYW4Iv36MoRLFYBIFgjIbRZgMApWBnMtBGQ0qJVqsFztdmADDU6/Xud8Z
gtIExGwFICXALxhhI2UGr5YJzviYDIsL8fLkryhiM2SBAKQkA0NqQlKqXwUoAAHQ6HXieB8uyuueNgd5
YBgpA199KSbRaXs9Fi9EDRAZB0AYRgTHWLdHGM1BL0Uop4brNnosI6y3GGLgQMFr/jx4ASCaTOHDgKQw
NDYFzgZ6RYAz1hNE7l8LY2BiqtepGMwgBALZt0+TkC0tRMgZobRBFITjnYIyDMUAIgVqtjgsXp0HUBWx
6LmWZ0FjuD+1gXZt2m6wBoGdRgu8HkFIt1T2VSsGxbahIodwq2hf9M+PzPN+3651tD0aR3tUo+TfcUvv
NNYAwXAQYEBGMITQaDXheACEEOGcIwwhe4OHLmQv4tXYZZa+wrSoqZ4nghCrSUoYhgdoA2FpAFPVqrQE
QgqADzwvAOUcymYRlxeB7PtzAxTd/fI2aWsBAPNuOGua8UuqXyNc3KY5hwcUEMusAFktjej+TUrInnsC
WLYPgnCMej8Mv+hjZNIxXHz6KIWe08NnnX7xhpezi6cQUAHoi9MxjYOs0eXGCE3XnfneoMXAues0FhOB
gjCGdSmB0YBQZvpnSmT4DAKZtlv4j0DoAxlaiYjEBrTWCwEejYcOyLLhNF5HWcBwLIsaBZe4MVbcCkdK
AAfh/ZbB4uSSTSTiOjSjSqFSqKJfn4fk+BGdw4hY471qYgaEwdoMf3HnongTS2zqdkCFaBTh8+DBOfnh
iGYchFrOQzQ4gne422IrF4Dg2Uv3J3hxiYIzBd+pp2/C3o77GpU05eyqMwgQkaAVgfHwcx44dw+bBnB1
FkcMFhxAcjuMgl8thZGQYSGlc8b7HuZmTyDf/guACHBzX5Y/PzKirrze2Xt+u+hf6GddVANGKHgghEIY
he/zRR+Kzs7Mz/X2ZOc5FDEQMjKGj27HzpdOb3extUbcXUPdYOJcv1mLS+a1UKgYuy7ccz8Rq+fCqrtK
pzBFOKy7948ePw/M8VCoVuzy/kLUd514pZTpUytGREW6iNtDcd/ut4V3O/WFgZOUyndt+a+9HcStRaKL
yz0/OpQeUVFlZomvhJeSRAMRyQDabxdTUFCYmJnRfJu279WqZjJkDmVkQ3WWa/V62CjPNcqdevxWejq4
57z3Ed99MbbFr943saE+//+3fO57e+efZM582u1YC/gVmzLt/9AY+kwAAACJ6VFh0U29mdHdhcmUAAHj
aKy8v18vMyy5OTixI1csvSgcANtgGWBBTylwAAAAASUVORK5CYII='
);

$ico = do {
    my $loader = Gtk2::Gdk::PixbufLoader->new();
    $loader->write($ico);
    $loader->close();
    $loader->get_pixbuf();
};

my $dialog = Gtk2::Dialog->new(
    get_label(),
    undef,
    'modal',
    'gtk-media-stop' => 'no',
    'gtk-media-record' => 'yes'
);

my $tview = Gtk2::TextView->new();
$tview->set_wrap_mode("word");
$tview->set_cursor_visible(FALSE);
$tview->set_editable(FALSE);
my $buffer = $tview->get_buffer();
my $frame = Gtk2::Frame->new(get_label());
$frame->set_border_width(5);
my $sw = Gtk2::ScrolledWindow->new (undef, undef);
$sw->set_shadow_type ('etched-out');
$sw->set_policy ('automatic', 'automatic');
$sw->set_size_request (500, 70);
$sw->set_border_width(5);
$sw->add($tview);
$frame->add($sw);

$dialog->vbox->add($frame);

my $pbar = Gtk2::ProgressBar->new();
$pbar->set_fraction(0);
$pbar->set_pulse_step(0.01);
$dialog->vbox->add($pbar);

$dialog->set_default_response('no');

$dialog->set_icon($ico);
$dialog->signal_connect(response => sub {
    if ($_[1] eq 'yes') {
        start_strip();
    } elsif ($_[1] eq 'no') {
        exit_gracefully();
    }
});

$dialog->show_all();

$dialog->signal_connect('delete-event'=> sub { 
    exit_gracefully(); Gtk2->main_quit();});
# $dialog->signal_connect('response' => sub { 
#     exit_gracefully(); Gtk2->main_quit();});
$dialog->signal_connect('close' => sub { 
    exit_gracefully(); Gtk2->main_quit();});

start_strip();

Gtk2->main();

close($in);

sub rip_helper {
    my $txt;
    if (not sysread($in, $txt, 4096)) {
        Gtk2::Helper->remove_watch($tag)
            or die "couldn't remove watcher";
        close($in);
        $buffer->set_text("Stopped");
        return TRUE;
    }
    chomp($txt);
    $pbar->pulse();
    $buffer->set_text($txt);
    TRUE;
}

sub exit_gracefully {
    kill TERM => $pid;
    kill KILL => $pid if kill 0 => $pid;
}

sub get_command {
    my $dir = $ENV{'HOME'} . "/" . $dl_dir;
    my ($serv) = grep s/File:\s+//, get_info();
    chomp($serv);
    my $command = "streamripper $serv -d $dir -o version -t 2>&1 |";
    return $command;
}

sub start_strip {
    if (kill 0 => $pid) {
        return FALSE;
    }
    my $command = get_command();
    $frame->set_label(get_label());
    $dialog->set_title(get_label());
    $pid = open($in, $command)
        or die "Unable to open pipe: $!\n";
    $tag = Gtk2::Helper->add_watch($in->fileno(), 'in', sub { rip_helper($in, $tag)});
}
sub get_info {
    return system( "sh -c 'pidof mocp >/dev/null'") ?
        "moc server not running" : `mocp -i`;
}

sub get_label {
    my ($radio) = grep s/^Title:\s+//, get_info();
    chomp($radio);
    $radio;
}
