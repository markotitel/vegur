-module(hstub_lookup).

-export([lookup_domain/1]).

-type domain() :: binary().
-type reason() :: herokuapp_redirect.

-export_type([domain/0,
              reason/0
             ]).

-spec lookup_domain(domain()) ->
                           {error, not_found} |
                           {redirect, reason(), hstub_domains:domain_group(), domain()} |
                           {ok, hstub_domains:domain_group()}.
lookup_domain(Domain) ->
    case hstub_domains:lookup(Domain) of
        undefined ->
            {error, not_found};
        {error, {herokuapp, DomainGroup, SuperDomain}} ->
            RedirectTo = create_redirect(SuperDomain),
            {redirect, herokuapp_redirect, DomainGroup, RedirectTo};
        {ok, _SuperDomain, DomainGroup} ->
            {ok, DomainGroup}
    end.

%% Internal
create_redirect(Domain) ->
    RootDomainToReplace = hstub_app:config(heroku_domain),
    RootDomainToReplaceWith = hstub_app:config(herokuapp_domain),
    re:replace(Domain, RootDomainToReplace, RootDomainToReplaceWith).
