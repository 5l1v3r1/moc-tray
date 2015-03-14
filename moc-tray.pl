#!/usr/bin/perl
# Author: Bartłomiej Palmowski, rotwang at crux dot org dot pl
# Licensed under GPLv3

use strict;
use warnings;

use Gtk2 -init;

use Pod::Usage qw(pod2usage);
use Pod::Text ();
use Getopt::Long;
use MIME::Base64;
use encoding 'utf8';
use Glib qw/TRUE FALSE/;
use constant MOCTRAY_VERSION => "0.4";
use constant CODENAME => "something something something dark side";
use constant CONF_GROUP_NAME => "moc-tray main";
#my $have_podviewer = eval "use Gtk2::Ex::PodViewer; 1";

my @termcmd;
my $opts = {};
my $conffile = $ENV{'HOME'} . '/' . ".moc-tray";
my $gkey = Glib::KeyFile->new();
my $pod;
{
    my @data = <DATA>;
    $pod = join '', @data;
}

my $tray_ico = decode_base64(
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

$tray_ico = do {
    my $loader = Gtk2::Gdk::PixbufLoader->new();
    $loader->write( $tray_ico );
    $loader->close();
    $loader->get_pixbuf();
};

sub popup_menu {
   my ($widget, $button, $time, $menu) = @_;

   if ($button == 3) {
       $menu->show_all();
       $menu->popup( undef, undef, undef, undef, $button, $time );
   }
}

sub info_popup {
    my $info = system( "sh -c 'pidof mocp >/dev/null'") ?
        "moc server not running" : `mocp -i`;
    $info = Glib::Markup::escape_text($info);
    $info =~ s{^(\w+):}{<small><i>$1</i></small>:}gm;
    my $msgbox = Gtk2::MessageDialog->new_with_markup(
        undef,
        'GTK_DIALOG_MODAL',
        'GTK_MESSAGE_INFO',
        'GTK_BUTTONS_OK',
        $info);
    $msgbox->set_title('Current song info');
    $msgbox->set_default_icon ($tray_ico);
    $msgbox->run();
    $msgbox->destroy();
}

sub help_popup {
    my $manual;
#     if ( $have_podviewer ) {
#         # fuckloads of gtk warnings here, but output is prettier ;>
#         $manual = Gtk2::Ex::PodViewer->new();
#         $manual->load(<DATA>);
#     } else {
    $manual = Gtk2::TextView->new();
    $manual->set_left_margin(5);
    $manual->set_cursor_visible(FALSE);
    $manual->set_editable(FALSE);
    $manual->set_wrap_mode('word');
    my $parser = Pod::Text->new();
    my $text;
    $parser->output_string(\$text);
    $parser->parse_string_document($pod);
    $manual->get_buffer->set_text($text);
#     }
    my $window = Gtk2::Window->new();
    $window->signal_connect (delete_event => sub { $window->destroy() });
    my $widget = Gtk2::ScrolledWindow->new();
    $widget->set_size_request(560, 500);
    $widget->set_policy( 'never', 'automatic');
    $widget->add_with_viewport($manual);
    $window->add($widget);
    $window->set_title('Help');
    $window->set_default_icon ($tray_ico);
    $window->show_all;
}

sub about_popup {
    my $credits = q/AUTHOR:

Bartłomiej Palmowski <rotwang@crux.org.pl>


CREDITS:

guys from:
    #perl at freenode
    #gtk-perl at gnome.org

Marcin "czaks" Łabanowski <chax@i-rpg.net>
    spec file and shell account hosting
fi9o
    testing

other people I've forgotten to mention/;
    my $about = Gtk2::AboutDialog->new();
    $about->set_artists ("original tray icon borrowed from nuoveXT2 " .
        "'rhythmbox-tray-icon.png'" .
        "\nrest of the artwork is generic gtk2 stuff");
    $about->set_authors($credits);
    $about->set_version(MOCTRAY_VERSION);
    $about->set_license("GPLv3");
    $about->set_logo($tray_ico);
    $about->set_program_name("moc-tray");
    $about->set_comments(CODENAME);
    $about->set_website("http://code.google.com/p/moc-tray/");
    $about->run();
    $about->destroy();
}

sub no_term_choosen {
    my $info = "Please choose terminal in the preferences dialog!";
    my $msgBox = Gtk2::MessageDialog->new(undef,
        'GTK_DIALOG_MODAL',
        'GTK_MESSAGE_ERROR',
        'GTK_BUTTONS_OK',
        $info);
    $msgBox->set_title('choose your terminal');
    $msgBox->set_default_icon($tray_ico);
    $msgBox->run();
    configure();
    $msgBox->destroy();
}

sub noconf {
    save_config();
    my $info = shift;
    $info = "$info config file found.";
    my $msgbox = Gtk2::MessageDialog->new(
        undef,
        'GTK_DIALOG_MODAL',
        'GTK_MESSAGE_WARNING',
        'GTK_BUTTONS_OK',
        $info);
    $msgbox->set_title('moc-tray config file');
    $msgbox->set_default_icon ($tray_ico);
    $msgbox->run();
    configure();
    $msgbox->destroy();
}

sub configure {
    my $window = Gtk2::Dialog->new('moc-tray configuration',
        undef,
        'destroy-with-parent',
        'gtk-cancel' => 'reject',
        'gtk-save' => 'accept',
    );
    $window->set_border_width(5);
    $window->signal_connect('delete-event'=> sub { $window->destroy() });
    $window->action_area->set_layout( "center" );
    my $vbox = $window->vbox();
    my $label = Gtk2::Label->new("choose one of the folowing:");
    $vbox->pack_start($label,TRUE,TRUE,5);
    my $combo_term = Gtk2::ComboBox->new_text();
    $combo_term->append_text("none");
    $combo_term->append_text("urxvt");
    $combo_term->append_text("xterm");
    $combo_term->append_text("gnome-terminal");
    $combo_term->set_active(0);
    $combo_term->signal_connect('changed' => sub{
        $opts->{'term_cmd'} = $combo_term->get_active_text();
    });
    $vbox->pack_start($combo_term,TRUE,FALSE,5);
    $label = Gtk2::Label->new("or enter custom term_cmd\n(see \"Help\" below):");
    $label->set_justify('center');
    $vbox->pack_start($label,TRUE,TRUE,5);
    my $entry = Gtk2::Entry->new();
    $vbox->pack_start($entry, TRUE, FALSE, 5);
    my $hsep = Gtk2::HSeparator->new();
    $vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $btn_startmoc = Gtk2::CheckButton->new("start moc server on startup");
    $btn_startmoc->set_active ($opts->{'startmoc'} ? TRUE : FALSE );
    $vbox->pack_start($btn_startmoc, TRUE, FALSE, 5);
    my $btn_exitmoc = Gtk2::CheckButton->new("exit moc server on close");
    $btn_exitmoc->set_active($opts->{'exitmoc'} ? TRUE : FALSE );
    $vbox->pack_start($btn_exitmoc, TRUE, FALSE, 5);
    $hsep = Gtk2::HSeparator->new();
    $vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $lbl = Gtk2::Label->new("moc-tray needs to be restarted\n" .
        "in order for options below to work");
    $lbl->set_justify('center');
    $vbox->pack_start($lbl, TRUE, FALSE, 5);
    $hsep = Gtk2::HSeparator->new();
    $vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $btn_tearoff = Gtk2::CheckButton->new("add tearoff menu item");
    $btn_tearoff->set_active($opts->{'tearoff'} ? TRUE : FALSE );
    $vbox->pack_start($btn_tearoff, TRUE, FALSE, 5);
    my $btn_killsrv= Gtk2::CheckButton->new("kill moc server button");
    $btn_killsrv->set_active($opts->{'killsrv_btn'} ? TRUE : FALSE );
    $vbox->pack_start($btn_killsrv, TRUE, FALSE, 5);
    $hsep = Gtk2::HSeparator->new();
    $vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $exp = Gtk2::Expander->new('experimental stuff');
    my $exp_vbox = Gtk2::VBox->new(FALSE, 5);
    $lbl = Gtk2::Label->new("WARNING!!\n" .
        "It might make your mocp explode!\n" .
        "Please refer to playlists in help section."
    );
    $lbl->set_justify('center');
    $exp_vbox->pack_start($lbl, TRUE, FALSE, 5);
    $hsep = Gtk2::HSeparator->new();
    $exp_vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $btn_playlists= Gtk2::CheckButton->new("multiple playlists");
    $btn_playlists->set_active($opts->{'playlists'} ? TRUE : FALSE );
    $exp_vbox->pack_start($btn_playlists, TRUE, FALSE, 5);
    $exp->add($exp_vbox);
    $vbox->pack_start($exp, TRUE, FALSE, 5);
    $hsep = Gtk2::HSeparator->new();
    $vbox->pack_start($hsep, TRUE, FALSE, 5);
    my $hbox = Gtk2::HBox->new(FALSE, 5);
    my $help_button = Gtk2::Button->new_from_stock('gtk-help');
    $help_button->signal_connect(clicked => \&help_popup );
    $hbox->pack_start($help_button, TRUE, FALSE, 5);
    my $about_button = Gtk2::Button->new_from_stock('gtk-about');
    $about_button->signal_connect(clicked => \&about_popup );
    $hbox->pack_start($about_button, TRUE, FALSE, 5);
    $vbox->pack_start($hbox, TRUE, TRUE, 5);
    $window->signal_connect(response => sub {
        if($_[1] =~ m/accept/) {
            if ($entry->get_text() !~ m/^\s*$/) {
                $opts->{'term_cmd'} = $entry->get_text();
            }
            parse_term_cmd();
            $opts->{'playlists'} = $btn_playlists->get_active();
            $opts->{'killsrv_btn'} = $btn_killsrv->get_active();
            $opts->{'tearoff'} = $btn_tearoff->get_active();
            $opts->{'startmoc'} = $btn_startmoc->get_active();
            $opts->{'exitmoc'} = $btn_exitmoc->get_active();
            save_config();
            $window->destroy();
        } else {
            $window->destroy();
        }
    });
    $window->set_default_icon($tray_ico);
    $window->show_all();
}

sub parse_term_cmd {
    if ($opts->{'term_cmd'} eq "urxvt") {
        @termcmd = qw/ urxvt -e mocp/;
    } elsif ($opts->{'term_cmd'} eq "xterm") {
        @termcmd = qw/ xterm -e mocp/;
    } elsif ($opts->{'term_cmd'} eq "gnome-terminal") {
        @termcmd = qw/ gnome-terminal -e mocp/;
    } elsif ($opts->{'term_cmd'} eq "none" or ! defined $opts->{'term_cmd'}) {
        no_term_choosen();
    } else {
        $opts->{'term_cmd'} =~ s/\%s/mocp/;
        @termcmd = split /\s+/, $opts->{'term_cmd'};
    }
}

sub error_box {
    my $die = shift;
    my $info = shift;
    my $errbox = Gtk2::MessageDialog->new(
        undef,
        'GTK_DIALOG_MODAL',
        'GTK_MESSAGE_ERROR',
        'GTK_BUTTONS_OK',
        $info);
    $errbox->set_title('moc-tray error');
    $errbox->set_default_icon($tray_ico);
    $errbox->run();
    $errbox->destroy();
    exit(1) if ($die);
}

sub parse_config {
    my %opt_hash;
    my @list = $gkey->get_keys(CONF_GROUP_NAME);
    foreach ($gkey->get_keys(CONF_GROUP_NAME)) {
        $opt_hash{$_} = $gkey->get_value(CONF_GROUP_NAME, $_);
    }
    return \%opt_hash;
}

sub save_config {
    foreach (keys %{$opts}) {
        $gkey->set_value(CONF_GROUP_NAME, $_, $opts->{$_});
    }
    open(my $fh, '>', $conffile) or die $!;
    print $fh $gkey->to_data();
}

sub spawn_term {
    system( "@termcmd &" );
}

sub playlist_menu {
    Gtk2::Stock->add ({
        stock_id => 'gtk-italic',
        label    => 'rename'
    });
    # FIXME: make $moc_dir user definable
    my $moc_dir = $ENV{'HOME'} . '/' . '.moc';
    my $default_playlist = 'playlist.m3u';
    my $default_m3u = 'default.m3u';
    my $backup = 'playlist.m3u.bak';
    chdir($moc_dir) or die $!;
    if (not -l $default_playlist) {
        open(my $orig, '<', $default_playlist) or die $!;
        open(my $bak, '>', $backup) or die $!;
        {
            local $/;
            my $cont = <$orig>;
            print $bak $cont;
        }
        close($orig);
        close($bak);
        rename $default_playlist, $default_m3u or die $!;
        symlink $default_m3u, $default_playlist or die $!;
    }
    my $menu = Gtk2::Menu->new();
    my $group = undef;
    foreach (<*.m3u>) {
        next if (/^$default_playlist$/);
        my ($lbl) = ($_ =~ m/(.*)\.m3u/);
        my $menu_item = Gtk2::RadioMenuItem->new_with_label($group, $lbl);
        $group = $menu_item->get_group();
        $menu_item->set_active((readlink $default_playlist eq $_) ? TRUE:FALSE);
        $menu_item->signal_connect('activate'=> sub {
            if ($_[0]->get_active) {
                unlink $default_playlist;
                system('mocp', '-c');
                symlink $_[1], $default_playlist or die $!;
            }
        }, $_);
        $menu->append($menu_item);
    }
    return $menu;
}

my $lock_exclusive = 2;
my $unlock = 8;
my $nb = 4;
my $lock_file = "/tmp/.moc-tray.lock";
open (my $fh, '>', $lock_file) or die "problem opening lock file: $!";
if (not flock $fh, ($lock_exclusive | $nb)) { 
    error_box(TRUE, "Another instance of moc-tray is already running, " .
        "if You're sure that's not the case, please " .
        "remove\n$lock_file\nand try again."
    );
}

if (! -f $conffile) {
    noconf('No');
} elsif ( ! -w _ or ! -r _ ) {
    error_box(
        TRUE,
        "$conffile not writable and/or readable, please check permissions!"
    );
} elsif (eval { $gkey->load_from_file($conffile, 'none'); 1 }) {
    $opts = parse_config();
    parse_term_cmd();
} else {
    noconf('Old or corrupted');
}

GetOptions ('help|h' => sub { pod2usage(-verbose => 1,
        -exitval => 0,
        -message => 'For more information see "Help" from "Preferences".' );
    },
    'version|v' => sub { print "moc-tray " . "version: " . MOCTRAY_VERSION . 
        "\n" . "codename: " . CODENAME . "\n"; exit 0; }
) or pod2usage();

my $tray = Gtk2::StatusIcon->new_from_pixbuf($tray_ico);
my $menu = Gtk2::Menu->new();

# replace execute with spawn
Gtk2::Stock->add ({
    stock_id => 'gtk-execute',
    label    => 'Spawn'
});

my $menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-media-play');
$menuItem->signal_connect('activate'=> sub { system( "mocp", "-p" ) });
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-media-stop');
$menuItem->signal_connect('activate'=> sub { system( "mocp", "-s" ) });
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-media-pause');
$menuItem->signal_connect('activate'=> sub { system( "mocp", "-G" ) });
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-media-next');
$menuItem->signal_connect('activate'=> sub { system( "mocp", "-f" ) });
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-media-previous');
$menuItem->signal_connect('activate'=> sub { system( "mocp", "-r" ) });
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-execute');
$menuItem->signal_connect('activate'=> \&spawn_term);
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-info');
$menuItem->signal_connect('activate', \&info_popup);
$menu->append($menuItem);

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-preferences');
$menuItem->signal_connect('activate', \&configure);
$menu->append($menuItem);

$menuItem = Gtk2::MenuItem->new_with_label('playlists');
$menuItem->set_submenu(playlist_menu());
$menu->append($menuItem) if ($opts->{'playlists'});

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-stop');
$menuItem->signal_connect('activate' => sub { system( "mocp", "-x" ) });
$menu->append($menuItem) if ($opts->{'killsrv_btn'});

$menuItem = Gtk2::ImageMenuItem->new_from_stock('gtk-quit');
$menuItem->signal_connect('activate' => sub { Gtk2->main_quit();
    system( "mocp", "-x" ) if ($opts->{'exitmoc'});
});
$menu->append($menuItem);

$menuItem = Gtk2::TearoffMenuItem->new();
$menu->append($menuItem) if ($opts->{'tearoff'});

$tray->set_tooltip("moc-tray");
$tray->signal_connect('activate' => \&spawn_term);
$tray->signal_connect('popup-menu'=> \&popup_menu, $menu);
$tray->set_visible(TRUE);

system( "mocp", "-S" ) if ( $opts->{'startmoc'} );

Gtk2->main();

flock $fh, ($unlock | $nb);
close($fh);
unlink($lock_file);
exit(0);
__END__

=head1 NAME

moc-tray - navigate Music On Console Player via tray icon

=head1 SYNOPSIS

    moc-tray [-v|--version|-h|--help]

=head1 DESCRIPTION

moc-tray is designed to give you easy access to F<mocp> basic functions via
graphical interface.

moc-tray docks into system tray, right click on the icon spawns menu which gives
you quick acces to basic commands like: play, stop, pause. Left click spawns
choosen terminal with mocp.

=head1 OPTIONS

=over 4

=item B<-v>, B<--version>

Print program version to STDOUT and exit.

=item B<-h>, B<--help>

Print usage to STDOUT and exit.

=back

=head1 THE term_cmd

Three supported terminals by default are xterm, urxvt and gnome-terminal. If
none of these are users choice, F<term_cmd> can be used to describe which
terminal should be used instead. The term_cmd can be set up via 'Preferences'
dialog, or configuration file. Put %s in a place where "mocp" should appear in
final command.

B<Examples:>

aterm -e %s

=head1 THE .moc-tray file

.moc-tray configuration file resides in users $HOME directory, is a key file
and can be edited by hand, but doing it via 'Preferences' dialog is preffered.
Options are selfexplantatory. Options that reffers to tearoff menuitem, kill moc
server button and multiple playlists requires moc-tray to be restarted. 

=head1 Experimental playlists

By default mocp operates on one playlist located in ~/.moc, idea with multiple
playlists comes down to makeing symlinks to default mocp playlist called
"playlist.m3u". When You enable "multiple playlists" and restart moc-tray
(the backup of your "playlist.m3u" will be made so if anything goes wrong you
will still be ablo to recover your original playlist (hopefuly)) You will be
able to put m3u files to Your ~/.moc and then choose them from a menu. However
You should close all mocp clients while switching between playlists, *B<if playlist
appears blank after switching, close all mocp clients and choose it again>*. There
is no playlist managing gui available (it would add awfully huge amount of code
to moc-tray script) so you have to put m3u playlists by Yourself into ~/.moc dir
and restart moc-tray.
B<F<WARNING>>: multiple playlist is just dirty trick, use it with caution.

B<Example:>
Firstly enable multiple playlists in Preferences dialog and restart moc-tray,
now to add some playlists:

$ touch ~/.moc/my_playlist.m3u

$ touch ~/.moc/another_playlist.m3u

after restarting moc-tray You will be able to choose from three playlists:
default, my_playlist and another_playlist. Remember about closing all mocp
clients before switching between playlists!

=head1 BUGS and FEATURE REQUESTS

B<F<rotwang@crux.org.pl>>

or

B<F<code.google.com/p/moc-tray/issues/list>>

=cut
