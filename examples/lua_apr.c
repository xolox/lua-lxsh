/* Miscellaneous functions module for the Lua/APR binding.
 *
 * Author: Peter Odding <peter@peterodding.com>
 * Last Change: January 8, 2011
 * Homepage: http://peterodding.com/code/lua/apr/
 * License: MIT
 */

#include "lua_apr.h"
#include <apr_portable.h>

/* Used to make sure that APR is only initialized once. */
static int apr_was_initialized = 0;

/* Used to locate global memory pool used by library functions. */
static int mp_regidx = LUA_NOREF;

/* luaopen_apr_core() initializes the binding and library. {{{1 */

int luaopen_apr_core(lua_State *L)
{
  apr_status_t status;

  /* Table of library functions. */
  luaL_Reg functions[] = {

    /* lua_apr.c -- the "main" file. */
    { "platform_get", lua_apr_platform_get },
    { "version_get", lua_apr_version_get },
    { "os_default_encoding", lua_apr_os_default_encoding },
    { "os_locale_encoding", lua_apr_os_locale_encoding },
    { "type", lua_apr_type },

    /* base64.c -- base64 encoding/decoding. */
    { "base64_encode", lua_apr_base64_encode },
    { "base64_decode", lua_apr_base64_decode },

    /* crypt.c -- cryptographic functions. */
    { "md5_init", lua_apr_md5_init },
    { "md5_encode", lua_apr_md5_encode },
    { "password_get", lua_apr_password_get },
    { "password_validate", lua_apr_password_validate },
    { "sha1_init", lua_apr_sha1_init },

    /* date.c -- date parsing. */
    { "date_parse_http", lua_apr_date_parse_http },
    { "date_parse_rfc", lua_apr_date_parse_rfc },

    /* dbm.c -- dbm routines. */
    { "dbm_open", lua_apr_dbm_open },
    { "dbm_getnames", lua_apr_dbm_getnames },

    /* env.c -- environment variable handling. */
    { "env_get", lua_apr_env_get },
    { "env_set", lua_apr_env_set },
    { "env_delete", lua_apr_env_delete },

    /* filepath.c -- filepath manipulation. */
    { "filepath_root", lua_apr_filepath_root },
    { "filepath_parent", lua_apr_filepath_parent },
    { "filepath_name", lua_apr_filepath_name },
    { "filepath_merge", lua_apr_filepath_merge },
    { "filepath_list_split", lua_apr_filepath_list_split },
    { "filepath_list_merge", lua_apr_filepath_list_merge },
    { "filepath_get", lua_apr_filepath_get },
    { "filepath_set", lua_apr_filepath_set },

    /* fnmatch.c -- filename matching. */
    { "fnmatch", lua_apr_fnmatch },
    { "fnmatch_test", lua_apr_fnmatch_test },

    /* io_dir.c -- directory manipulation. */
    { "temp_dir_get", lua_apr_temp_dir_get },
    { "dir_make", lua_apr_dir_make },
    { "dir_make_recursive", lua_apr_dir_make_recursive },
    { "dir_remove", lua_apr_dir_remove },
    { "dir_remove_recursive", lua_apr_dir_remove_recursive },
    { "dir_open", lua_apr_dir_open },

    /* io_file.c -- file i/o handling. */
#   if APR_MAJOR_VERSION > 1 || (APR_MAJOR_VERSION == 1 && APR_MINOR_VERSION >= 4)
    { "file_link", lua_apr_file_link },
#   endif
    { "file_copy", lua_apr_file_copy },
    { "file_append", lua_apr_file_append },
    { "file_rename", lua_apr_file_rename },
    { "file_remove", lua_apr_file_remove },
    { "file_mtime_set", lua_apr_file_mtime_set },
    { "file_attrs_set", lua_apr_file_attrs_set },
    { "file_perms_set", lua_apr_file_perms_set },
    { "stat", lua_apr_stat },
    { "file_open", lua_apr_file_open },

    /* io_net.c -- network i/o handling. */
    { "socket_create", lua_apr_socket_create },
    { "hostname_get", lua_apr_hostname_get },
    { "host_to_addr", lua_apr_host_to_addr },
    { "addr_to_host", lua_apr_addr_to_host },

    /* io_pipe.c -- pipe i/o handling. */
    { "pipe_open_stdin", lua_apr_pipe_open_stdin },
    { "pipe_open_stdout", lua_apr_pipe_open_stdout },
    { "pipe_open_stderr", lua_apr_pipe_open_stderr },
    { "namedpipe_create", lua_apr_namedpipe_create },
    { "pipe_create", lua_apr_pipe_create },

    /* proc -- process handling. */
    { "proc_create", lua_apr_proc_create },
    { "proc_detach", lua_apr_proc_detach },
#   if APR_HAS_FORK
    { "proc_fork", lua_apr_proc_fork },
#   endif

    /* str.c -- string handling. */
    { "strnatcmp", lua_apr_strnatcmp },
    { "strnatcasecmp", lua_apr_strnatcasecmp },
    { "strfsize", lua_apr_strfsize },
    { "tokenize_to_argv", lua_apr_tokenize_to_argv },

    /* time.c -- time management */
    { "sleep", lua_apr_sleep },
    { "time_now", lua_apr_time_now },
    { "time_explode", lua_apr_time_explode },
    { "time_implode", lua_apr_time_implode },
    { "time_format", lua_apr_time_format },

    /* uri.c -- URI parsing/unparsing. */
    { "uri_parse", lua_apr_uri_parse },
    { "uri_unparse", lua_apr_uri_unparse },
    { "uri_port_of_scheme", lua_apr_uri_port_of_scheme },

    /* user.c -- user/group identification. */
    { "user_get", lua_apr_user_get },
    { "user_homepath_get", lua_apr_user_homepath_get },

    /* uuid.c -- UUID generation. */
    { "uuid_get", lua_apr_uuid_get },
    { "uuid_format", lua_apr_uuid_format },
    { "uuid_parse", lua_apr_uuid_parse },

    /* xlate.c -- character encoding translation. */
    { "xlate", lua_apr_xlate },

    { NULL, NULL }
  };

  /* Initialize the library (only once per process). */
  if (!apr_was_initialized) {
    if ((status = apr_initialize()) != APR_SUCCESS)
      raise_error_status(L, status);
    if (atexit(apr_terminate) != 0)
      raise_error_message(L, "Lua/APR: Failed to register apr_terminate()");
    apr_was_initialized = 1;
 }

  /* Create the table of global functions. */
  lua_createtable(L, 0, count(functions));
  luaL_register(L, NULL, functions);

  /* Let callers of process:user_set() know whether it requires a password. */
  lua_pushboolean(L, APR_PROCATTR_USER_SET_REQUIRES_PASSWORD);
  lua_setfield(L, -2, "user_set_requires_password");

  /* Let callers of apr.socket_create() know whether it supports IPv6. */
  lua_pushboolean(L, APR_HAVE_IPV6);
  lua_setfield(L, -2, "socket_supports_ipv6");

  return 1;
}

/* apr.platform_get() -> name {{{1
 * 
 * Get the name of the platform for which the Lua/APR binding was compiled.
 * Returns one of the following strings:
 *
 *  - `'UNIX'`
 *  - `'WIN32'`
 *  - `'NETWARE'`
 *  - `'OS2'`
 *
 * Please note that the labels returned by `apr.platform_get()` don't imply
 * that these platforms are fully supported; the author of the Lua/APR binding
 * doesn't have NETWARE and OS2 environments available for testing.
 */

int lua_apr_platform_get(lua_State *L)
{
# if defined(WIN32)
  lua_pushstring(L, "WIN32");
# elif defined(NETWARE)
  lua_pushstring(L, "NETWARE");
# elif defined(OS2)
  lua_pushstring(L, "OS2");
# else
  lua_pushstring(L, "UNIX");
# endif
  return 1;
}

/* apr.version_get() -> apr_version, apu_version {{{1
 *
 * Get the version numbers of the Apache Portable Runtime and its utility
 * library as strings. Each string contains three numbers separated by dots.
 * The numbers have the following meaning:
 *
 *  - The 1st number is used for major [API] [api] changes that can cause
 *    compatibility problems between the Lua/APR binding and the APR and
 *    APR-util libraries
 *  - The 2nd number is used for minor API changes that shouldn't impact
 *    existing functionality in the Lua/APR binding
 *  - The 3rd number is used exclusively for bug fixes
 *
 * This function can be useful when you want to know whether a certain bug fix
 * has been applied to APR and/or APR-util or if you want to report a bug in
 * APR, APR-util or the Lua/APR binding.
 *
 * If you're looking for the version of the Lua/APR binding you can use the
 * `apr._VERSION` string, but note that Lua/APR currently does not use the
 * above versioning rules.
 *
 * [api]: http://en.wikipedia.org/wiki/Application_programming_interface
 */

int lua_apr_version_get(lua_State *L)
{
  lua_pushstring(L, apr_version_string());
  lua_pushstring(L, apu_version_string());
  return 2;
}

/* apr.os_default_encoding() -> name {{{1
 *
 * Get the name of the system default character set as a string.
 */

int lua_apr_os_default_encoding(lua_State *L)
{
  lua_pushstring(L, apr_os_default_encoding(to_pool(L)));
  return 1;
}

/* apr.os_locale_encoding() -> name {{{1
 *
 * Get the name of the current locale character set as a string. If the current
 * locale's data cannot be retrieved on this system, the name of the system
 * default character set is returned instead.
 */

int lua_apr_os_locale_encoding(lua_State *L)
{
  lua_pushstring(L, apr_os_locale_encoding(to_pool(L)));
  return 1;
}

/* apr.type(object) -> name {{{1
 *
 * Return the type of a userdata value as a string. If @object is of a known
 * type one of the strings `'file'`, `'directory'`, `'socket'`, `'process'` or
 * `'dbm'` will be returned, otherwise nothing is returned.
 */

int lua_apr_type(lua_State *L)
{
  lua_apr_objtype *types[] = {
    &lua_apr_file_type,
    &lua_apr_dir_type,
    &lua_apr_socket_type,
    &lua_apr_proc_type,
    &lua_apr_dbm_type
  };
  int i;

  lua_settop(L, 1);
  luaL_checktype(L, 1, LUA_TUSERDATA);
  lua_getmetatable(L, 1);

  for (i = 0; i < count(types); i++) {
    get_metatable(L, types[i]);
    if (lua_rawequal(L, 2, 3)) {
      lua_pushstring(L, types[i]->friendlyname);
      return 1;
    }
    lua_pop(L, 1);
  }

  return 0;
}

/* to_pool() returns the global memory pool from the registry. {{{1 */

apr_pool_t *to_pool(lua_State *L)
{
  apr_pool_t *memory_pool;
  apr_status_t status;

  luaL_checkstack(L, 1, "not enough stack space to get memory pool");

  if (mp_regidx == LUA_NOREF) {
    status = apr_pool_create(&memory_pool, NULL);
    if (status != APR_SUCCESS)
      raise_error_status(L, status);
    lua_pushlightuserdata(L, memory_pool);
    mp_regidx = luaL_ref(L, LUA_REGISTRYINDEX);
  } else {
    lua_rawgeti(L, LUA_REGISTRYINDEX, mp_regidx);
    memory_pool = lua_touserdata(L, -1);
    apr_pool_clear(memory_pool);
    lua_pop(L, 1);
  }

  return memory_pool;
}

/* status_to_message() converts APR status codes to error messages. {{{1 */

int status_to_message(lua_State *L, apr_status_t status)
{
  char message[512];
  apr_strerror(status, message, count(message));
  lua_pushstring(L, message);
  return 1;
}

/* push_status() returns true for APR_SUCCESS or the result of status_to_message(). {{{1 */

int push_status(lua_State *L, apr_status_t status)
{
  if (status == APR_SUCCESS) {
    lua_pushboolean(L, 1);
    return 1;
  } else {
    return push_error_status(L, status);
  }
}

/* push_error_status() converts APR status codes to (nil, message, code). {{{1 */

int push_error_status(lua_State *L, apr_status_t status)
{
  lua_pushnil(L);
  status_to_message(L, status);
  status_to_name(L, status);
  return 3;
}

/* new_object() allocates userdata of the given type. {{{1 */

void *new_object(lua_State *L, lua_apr_objtype *T)
{
  void *object;

  object = lua_newuserdata(L, T->objsize);
  if (object != NULL) {
    memset(object, 0, T->objsize);
    get_metatable(L, T);
    lua_setmetatable(L, -2);
    getdefaultenv(L);
    lua_setfenv(L, -2);
  }
  return object;
}

void getdefaultenv(lua_State *L) /* {{{1 */
{
  const char *key = "Lua/APR default environment for userdata";

  lua_getfield(L, LUA_REGISTRYINDEX, key);
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    lua_newtable(L);
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, key);
  }
}

/* check_object() validates objects created by new_object(). {{{1 */

void *check_object(lua_State *L, int idx, lua_apr_objtype *T)
{
  int valid = 0;
  get_metatable(L, T);
  lua_getmetatable(L, idx);
  valid = lua_rawequal(L, -1, -2);
  lua_pop(L, 2);
  if (valid)
    return lua_touserdata(L, idx);
  luaL_typerror(L, idx, T->typename);
  return NULL;
}

/* get_metatable() returns the metatable for the given type. {{{1 */

int get_metatable(lua_State *L, lua_apr_objtype *T)
{
  luaL_getmetatable(L, T->typename);
  if (lua_type(L, -1) != LUA_TTABLE) {
    lua_pop(L, 1);
    luaL_newmetatable(L, T->typename);
    luaL_register(L, NULL, T->metamethods);
    lua_newtable(L);
    luaL_register(L, NULL, T->methods);
    lua_setfield(L, -2, "__index");
  }
  return 1;
}

/* vim: set ts=2 sw=2 et tw=79 fen fdm=marker : */
