package SPPM::Web::Controller::Login;
use Moose;
use utf8;

BEGIN {extends 'Catalyst::Controller'; }

sub fbauthenticate :Path('/fblogin') :Args(0) {
	my ($self, $c) = @_;
	if ($c->authenticate()) {
		$c->log->debug($c->user->session_uid);
		$c->log->debug($c->user->session_key);
		$c->log->debug($c->user->session_expires);
		}
	$c->res->redirect('/');
}

sub login :Path('/login') :Args(0) {
	my ($self, $c) =@_;
	$c->stash( template => \<<LOGINOPTIONS
<a href="/loginfacebook">login via facebook</a>
LOGINOPTIONS
		, );
	}

sub login_facebook : Path('/loginfacebook') : Args(0) {
    my ( $self, $c ) = @_;
    my $fb_app_id = '171501766212404';
    $c->stash( template => \<<FBLOGIN
    <p><fb:login-button autologoutlink="true"></fb:login-button></p>
    <p><fb:like></fb:like></p>

    <div id="fb-root"></div>
    <script>
      window.fbAsyncInit = function() {
        FB.init({appId: '$fb_app_id', status: true, cookie: true,
                 xfbml: true});

	FB.Event.subscribe('auth.sessionChange', function(response) {
	  if (response.session) {
	    // A user has logged in, and a new cookie has been saved
	    window.location="/fblogin"; //redirects user to our facebook login so we can validate him and get his user id.
	  } else {
	    // The user has logged out, and the cookie has been cleared
	    window.location="/"; 
	  }
	});
      };

      (function() {
        var e = document.createElement('script');
        e.type = 'text/javascript';
        e.src = document.location.protocol +
          '//connect.facebook.net/en_US/all.js';
        e.async = true;
        document.getElementById('fb-root').appendChild(e);
      }());
    </script>
FBLOGIN
);

    # If either of above don't work out, send to the login page
    $c->detach(qw/SPPM::Web::Controller::Root index/) if ($c->user_exists);
}




sub logout : Path('/logout') : Args(0) {
    my ( $self, $c ) = @_;

    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->response->redirect( $c->uri_for('/') );
}



1;
