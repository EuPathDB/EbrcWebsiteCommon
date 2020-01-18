import { compose, replace, truncate } from 'lodash/fp';
import React from 'react';
import TwitterTimeline from 'ebrc-client/components/TwitterTimeline';
import { Seq } from 'wdk-client/Utils/IterableUtils';

import './News.scss';
import { projectId } from 'ebrc-client/config';

const transformNewItem = compose(
  truncate({ length: 200 }),
  replace(/(<([^>]+)>)/ig, '') // strip html chars
);

const getProfileIdFromTwitterUrl =
  replace(/(?:.*)twitter.com\/(.*)$/, '$1')

const News = ({ twitterUrl, webAppUrl, news, error, newsUrl = `${webAppUrl}/app/static-content/${projectId}/news.html` }) =>
  <React.Fragment>
    <div className="stack wdk-Showcase">
      <div className="row wdk-Showcase-HeadingRow">
        <div className="box">
          <h2>News</h2>
        </div>
      </div>
      <div className="row wdk-Showcase-ContentRow">
        <div className="News">
          <div className="NewsList">
          {error && <div className="NewsLoadError"><em>Error loading news items.</em></div>}
          {Seq.from(news ? news.records : Seq.empty())
              .map(({ attributes }) => (
                <div className="NewsEntry" key={attributes.tag}>
                  <h4 className="NewsHeadline">
                    <a href={`${newsUrl}#${attributes.tag}`} target="_blank">
                      {attributes.headline}
                    </a>
                  </h4>
                  <div className="NewsDate">{new Date(attributes.date.replace(/-/g, '\/')).toDateString()}</div>
                  <div className="NewsTeaser">
                    {transformNewItem(attributes.item)} <a href={`${newsUrl}#${attributes.tag}`} > read more</a>
                  </div>
                </div>
              ))
          //    .take(2)
              .toArray()}
          </div>
          <a className="AllNewsLink" href={newsUrl}>See all news</a>
        </div>
        <TwitterTimeline theme="light" linkColor="#0f5970" height={1140} profileId={getProfileIdFromTwitterUrl(twitterUrl)}/>
      </div>
    </div>
  </React.Fragment>

export default News;
