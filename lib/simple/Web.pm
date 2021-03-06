package simple::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Data::Dumper;
use lib 'lib/simple';
use db;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = "Kossy training";
        $app->($self,$c);
    }
};


get '/' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    my $itr = $self->teng->search('todos');
    $c->render('index.tx', {class_home => "active", itr => $itr});
};

get '/form' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('form.tx', {class_post => "active"});
};

get '/edit/${id:[0-9]+}' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('form.tx', {class_post => "active"});
};


post '/create' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
	my $result = $c->req->validator([
		'name' => {
			rule => [['NOT_NULL', 'Input some message.']]
		}
	]);
    my $itr = $self->teng->search('todos');
	if( $result->has_error ){
		return $c->render('index.tx', 
			{class_post => "active", info => $result->errors->{name}, itr => $itr});
	}
    my $name = $result->valid->get('name');
	my $comment = $result->valid->get('comment');
    my $deadline = $result->valid->get('deadline');
	my $row = $self->teng->insert('todos' => {
		name => $name,
        comment => $comment,
        deadline => $deadline
	});
    $itr = $self->teng->search('todos');
    $c->render('index.tx', {class_home => "active", info => "You have posted: " . $name , itr => $itr });
};



post '/update' => [qw/set_title/] => sub {
    my ( $self, $c ) = @_;
    my $result = $c->req->validator([
        'name' => {
            rule => [['NOT_NULL', 'Input some message.']]
        },
        'id' => {rule => [['NOT_NULL', 'Error.']]},
    ]);
    my $itr = $self->teng->search('todos');
    if( $result->has_error ){
        return $c->render('index.tx', 
            {class_home => "active", itr=>$itr, info => $result->errors->{id}});
    }
    my $id = $result->valid->get('id');
    my $name = $result->valid->get('name');
    my $comment = $result->valid->get('comment');
    my $row = $self->teng->single('todos', {id => $id});
    $row->update({
        name => $name,
        comment => $comment,
        updated_at => time
    });
    $itr = $self->teng->search('todos');
    $c->render('index.tx', {class_home => "active", info => "You have updated: " . $name, itr => $itr  });
           
};


get '/delete/{id:[0-9]+}' => [qw/set_title/] => sub {
    my ( $self, $c ) = @_;
    my $id = $c->args->{id};
    my @rows = $self->teng->search('todos', {id => $id});
    my $name = $rows[0]->get_column("name");
    $self->teng->delete('todos', {id => $id});
    my $itr = $self->teng->search('todos', {id => $id});
    $c->render('index.tx', {class_home => "active", info => "You have deleted: " . $name , itr => $itr });
};




get '/json' => sub {
    my ( $self, $c )  = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json({ greeting => $result->valid->get('q') });
};






1;

