<?php
declare(strict_types=1);

namespace Plaisio\RequestLogger;

use Plaisio\C;
use Plaisio\PlaisioObject;
use Throwable;

/**
 * An HTTP page request logger for light and development websites.
 */
class RequestLoggerLight extends PlaisioObject implements RequestLogger
{
  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Whether the HTTP page request details (i.e., cookies, POST variables and queries) must be logged.
   *
   * @var bool
   *
   * @api
   * @since 1.0.0
   */
  public bool $logRequestDetails = false;

  /**
   * Whether the HTTP page request must be logged.
   *
   * @var bool
   *
   * @api
   * @since 1.0.0
   */
  public bool $logRequests = true;

  /**
   * The ID of the logged page request.
   *
   * @var int|null
   *
   * @api
   * @since 1.0.0
   */
  public ?int $rqlId = null;

  //--------------------------------------------------------------------------------------------------------------------

  /**
   * Logs the HTTP page request.
   *
   * @param int|null $status The HTTP status code.
   *
   * @api
   * @since 1.0.0
   */
  public function logRequest(?int $status): void
  {
    if ($this->logRequests)
    {
      $time0 = $this->nub->request->requestTime;

      $ip = $this->nub->request->remoteIp;
      if ($ip!==null && !str_contains($ip, ':'))
      {
        $ip = '::ffff:'.$ip;
      }

      try
      {
        $cmpId = $this->nub->company->cmpId;
      }
      catch (Throwable $e)
      {
        $cmpId = null;
      }

      try
      {
        $usrId = $this->nub->session->usrId;
      }
      catch (Throwable $e)
      {
        $usrId = null;
      }

      $this->rqlId = $this->nub->DL->abcRequestLoggerLightInsertRequest( //
        $this->nub->session->sesId,
        $cmpId,
        $usrId,
        $this->nub->requestHandler->getPagId(),
        mb_substr($this->nub->request->requestUri, 0, C::LEN_RQL_REQUEST),
        mb_substr($this->nub->request->method, 0, C::LEN_RQL_METHOD),
        mb_substr($this->nub->request->referrer ?? '', 0, C::LEN_RQL_REFERRER),
        ($ip!==null) ? inet_pton($ip) : null,
        mb_substr($this->nub->request->acceptLanguage, 0, C::LEN_RQL_ACCEPT_LANGUAGE),
        mb_substr($this->nub->request->userAgent ?? '', 0, C::LEN_RQL_USER_AGENT),
        $status,
        count($this->nub->DL->getQueryLog()),
        ($time0!==null) ? microtime(true) - $time0 : null);

      if ($this->logRequestDetails)
      {
        $oldLogQueries             = $this->nub->DL->logQueries;
        $this->nub->DL->logQueries = false;

        $this->requestLogQuery();
        $this->requestLogPost($this->nub->request->post);
        $this->requestLogCookie($this->nub->request->cookie);

        $this->nub->DL->logQueries = $oldLogQueries;
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the (by the user agent) sent cookies into the database.
   *
   * Usage of this method on production environments is not recommended.
   *
   * @param array       $cookies    The cookies.
   * @param string|null $parentName must not be used, intended for use by recursive calls only.
   */
  private function requestLogCookie(array $cookies, ?string $parentName = null): void
  {
    foreach ($cookies as $name => $value)
    {
      $fullName = ($parentName===null) ? (string)$name : $parentName.'['.$name.']';

      if (is_array($value))
      {
        $this->requestLogCookie($value, $fullName);
      }
      else
      {
        $this->nub->DL->abcRequestLoggerLightInsertCookie($this->rqlId, $fullName, $value);
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the POST variables into the database.
   *
   * Usage of this method on production environments is not recommended.
   *
   * @param array       $post       The POST variables.
   * @param string|null $parentName Must not be used (except for recursive calls).
   */
  private function requestLogPost(array $post, ?string $parentName = null): void
  {
    foreach ($post as $name => $value)
    {
      $fullName = ($parentName===null) ? (string)$name : $parentName.'['.$name.']';

      if (is_array($value))
      {
        $this->requestLogPost($value, $fullName);
      }
      else
      {
        // Don't log passwords.
        if (is_string($name) && str_contains($name, 'password'))
        {
          $value = str_repeat('*', mb_strlen($name));
        }

        $this->nub->DL->abcRequestLoggerLightInsertPost($this->rqlId, $fullName, $value);
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the executed SQL queries into the database.
   */
  private function requestLogQuery(): void
  {
    $queries = $this->nub->DL->getQueryLog();

    foreach ($queries as $query)
    {
      $this->nub->DL->abcRequestLoggerLightInsertQuery($this->rqlId, $query['query'], $query['time']);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------------------------------------------
