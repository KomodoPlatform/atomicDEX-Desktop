
//! Project Headers
#include "atomicdex/api/coingecko/coingecko.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/services/price/coingecko/coingecko.wallet.charts.hpp"
#include "atomicdex/services/price/global.provider.hpp"

//! Constructor / Destructor
namespace atomic_dex
{
    coingecko_wallet_charts_service::coingecko_wallet_charts_service(entt::registry& registry, ag::ecs::system_manager& system_manager) :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("coingecko_wallet_charts_service created");
        m_update_clock = std::chrono::high_resolution_clock::now();
    }

    coingecko_wallet_charts_service::~coingecko_wallet_charts_service() { SPDLOG_INFO("coingecko_wallet_charts_service destroyed"); }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    coingecko_wallet_charts_service::generate_fiat_chart()
    {
        SPDLOG_INFO("Generate fiat chart");
        auto                     chart_registry = this->m_chart_data_registry.get();
        //std::vector<std::string> keys;
        //keys.reserve(chart_registry.size());
        //for (auto&& [key, value]: chart_registry) { keys.emplace_back(key); }
        nlohmann::json out = nlohmann::json::array();
        const auto& data = chart_registry.begin()->second[WalletChartsCategories::OneMonth];
        const auto& mm2 = m_system_manager.get_system<mm2_service>();
        for (std::size_t idx = 0; idx < data.size(); ++idx)
        {
            nlohmann::json cur = nlohmann::json::object();
            cur["timestamp"] = data[idx][0];
            t_float_50 price(0);
            for (auto&& [key, value]: chart_registry) {
                price += t_float_50(value[WalletChartsCategories::OneMonth][idx][1].get<float>()) * mm2.get_balance(key);
            }
            cur["price"] = utils::format_float(price);
            out.push_back(cur);
        }
        SPDLOG_INFO("out: {}", out.dump(4));
    }

    void
    coingecko_wallet_charts_service::fetch_data_of_single_coin(const coin_config& cfg)
    {
        SPDLOG_INFO("fetch charts data of {} {}", cfg.ticker, cfg.coingecko_id);
        //! 30 days
        {
            try
            {
                t_coingecko_market_chart_request request{.id = cfg.coingecko_id, .vs_currency = "usd", .days = "30", .interval = "daily"};
                auto                             resp = atomic_dex::coingecko::api::async_market_charts(std::move(request)).get();
                std::string                      body = TO_STD_STR(resp.extract_string(true).get());
                if (resp.status_code() == 200)
                {
                    m_chart_data_registry->operator[](cfg.ticker)[WalletChartsCategories::OneMonth] = nlohmann::json::parse(body).at("prices");
                    SPDLOG_INFO("Successfully retrieve chart data for: {} {}", cfg.ticker, cfg.coingecko_id);
                }
            }
            catch (const std::exception& error)
            {
                SPDLOG_ERROR("Caught exception: {} - retrying.", error.what());
                fetch_data_of_single_coin(cfg);
            }
        }
    }

    void
    coingecko_wallet_charts_service::fetch_all_charts_data()
    {
        SPDLOG_INFO("fetch all charts data");
        const auto coins           = this->m_system_manager.get_system<portfolio_page>().get_global_cfg()->get_enabled_coins();
        auto*      portfolio_model = this->m_system_manager.get_system<portfolio_page>().get_portfolio();
        auto       final_task      = m_taskflow.emplace([this]() { this->generate_fiat_chart(); }).name("Post task");
        for (auto&& [coin, cfg]: coins)
        {
            if (cfg.coingecko_id == "test-coin")
            {
                continue;
            }
            auto res =
                portfolio_model->match(portfolio_model->index(0, 0), portfolio_model::TickerRole, QString::fromStdString(coin), 1, Qt::MatchFlag::MatchExactly);
            // assert(not res.empty());
            if (not res.empty())
            {
                t_float_50 balance = safe_float(portfolio_model->data(res.at(0), portfolio_model::MainCurrencyBalanceRole).toString().toStdString());
                if (balance > 0)
                {
                    final_task.succeed(m_taskflow.emplace([this, cfg = cfg]() { fetch_data_of_single_coin(cfg); }).name(cfg.ticker));
                }
            }
        }
        SPDLOG_INFO("taskflow: {}", m_taskflow.dump());
        m_executor.run(m_taskflow);
    }
} // namespace atomic_dex

//! Public override
namespace atomic_dex
{
    void
    coingecko_wallet_charts_service::update()
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1min)
        {
            {
                SPDLOG_INFO("Waiting for previous call to be finished");
                m_executor.wait_for_all();
                m_taskflow.clear();
            }
            fetch_all_charts_data();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }
} // namespace atomic_dex