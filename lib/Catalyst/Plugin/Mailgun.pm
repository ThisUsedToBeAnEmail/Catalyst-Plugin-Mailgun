package Catalyst::Plugin::Mailgun;

use Moo;

use WWW::Mailgun;
use Template;

has [qw/mailgun mailgun_template/] => (
    is => 'ro',
    lazy => 1,
    builder => 1,
);

sub _build_mailgun {
    my $config = $_[0]->config->{'Plugin::Mailgun'}->{setup};
    return WWW::Mailgun->new($config);
}

sub _build_mailgun_template {
    my $template = $_[0]->config->{'Plugin::Mailgun'}->{template};
    return Template->new($template);
}

sub send_email {
    my ($c, $args) = @_;
    
    if (my $template = delete $args->{template}){
        my $template_args = delete $args->{template_args} || {};
        $args->{html} = $c->_render_email_html($template, $template_args);
    }
    
    $c->mailgun->send($args);
    return $args;
}

sub _render_email_html {
    my $tt;
    unless( $_[0]->mailgun_template->process($_[1], $_[2], \$tt) ){
        die "template failed to process\n";
    }
    return $tt;
}

1;
